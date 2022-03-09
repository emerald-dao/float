import NonFungibleToken from "../core-contracts/NonFungibleToken.cdc"
import MetadataViews from "../core-contracts/MetadataViews.cdc"
import SharedAccount from "../sharedaccount/SharedAccount.cdc"

pub contract FLOAT: NonFungibleToken {

    /***********************************************/
    /******************** PATHS ********************/
    /***********************************************/

    pub let FLOATCollectionStoragePath: StoragePath
    pub let FLOATCollectionPublicPath: PublicPath
    pub let FLOATEventsStoragePath: StoragePath
    pub let FLOATEventsPublicPath: PublicPath
    pub let FLOATEventsPrivatePath: PrivatePath

    /************************************************/
    /******************** EVENTS ********************/
    /************************************************/

    pub event ContractInitialized()
    pub event FLOATMinted(id: UInt64, eventHost: Address, eventId: UInt64, eventImage: String, recipient: Address, serial: UInt64)
    pub event FLOATClaimed(id: UInt64, eventHost: Address, eventId: UInt64, eventImage: String, eventName: String, recipient: Address, serial: UInt64)
    pub event FLOATDestroyed(id: UInt64, eventHost: Address, eventId: UInt64, serial: UInt64, lastOwner: Address)
    pub event FLOATTransferred(id: UInt64, from: Address, to: Address, eventHost: Address, eventId: UInt64, serial: UInt64)
    pub event FLOATEventCreated(eventId: UInt64, description: String, host: Address, image: String, name: String, url: String)
    pub event FLOATEventCreatedBySharedMinter(forHost: Address, bySharedMinter: Address, eventId: UInt64)
    pub event FLOATEventDestroyed(eventId: UInt64, host: Address, name: String)

    // Throw away for standard.pub event Deposit(id: UInt64, to: Address?)
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id: UInt64, to: Address?)

    /***********************************************/
    /******************** STATE ********************/
    /***********************************************/

    // The total amount of FLOATs that have ever been
    // created (does not go down when a FLOAT is destroyed)
    pub var totalSupply: UInt64
    // The total amount of FLOATEvents that have ever been
    // created (does not go down when a FLOATEvent is destroyed)
    pub var totalFLOATEvents: UInt64

    /***********************************************/
    /**************** FUNCTIONALITY ****************/
    /***********************************************/

    // A helpful wrapper to contain an address, 
    // the id of a FLOAT, and its serial
    pub struct TokenIdentifier {
        pub let id: UInt64
        pub let address: Address
        pub let serial: UInt64

        init(_id: UInt64, _address: Address, _serial: UInt64) {
            self.id = _id
            self.address = _address
            self.serial = _serial
        }
    }

    // Represents a FLOAT
    pub resource NFT: NonFungibleToken.INFT, MetadataViews.Resolver {
        // The `uuid` of this resource
        pub let id: UInt64

        pub let dateReceived: UFix64
        pub let eventDescription: String
        pub let eventHost: Address
        pub let eventId: UInt64
        pub let eventImage: String
        pub let eventName: String
        pub let originalRecipient: Address
        pub let serial: UInt64

        // A capability that points to the FLOATEvents this FLOAT is from.
        // There is a chance the event host unlinks their event from
        // the public, in which case it's impossible to know details
        // about the event. Which is fine, since we store the
        // crucial data to know about the FLOAT in the FLOAT itself.
        pub let eventsCap: Capability<&FLOATEvents{FLOATEventsPublic, MetadataViews.ResolverCollection}>
        
        // Helper function to get the metadata of the event 
        // this FLOAT is from.
        pub fun getEventMetadata(): FLOATEventMetadata? {
            if let resolver = self.eventsCap.borrow()?.borrowViewResolver(id: self.eventId) {
                let view = resolver.resolveView(Type<FLOATEventMetadata>()) 
                return view as! FLOATEventMetadata?
            }
            return nil
        }

        pub fun getViews(): [Type] {
             return [
                Type<MetadataViews.Display>(),
                Type<TokenIdentifier>(),
                Type<FLOATEventMetadata>()
            ]
        }

        pub fun resolveView(_ view: Type): AnyStruct? {
            switch view {
                case Type<MetadataViews.Display>():
                    return MetadataViews.Display(
                        name: self.eventName, 
                        description: self.eventDescription, 
                        file: MetadataViews.IPFSFile(cid: self.eventImage, path: nil)
                    )
                case Type<TokenIdentifier>():
                    return TokenIdentifier(
                        _id: self.id, 
                        _address: self.owner!.address,
                        _serial: self.serial
                    ) 
                case Type<FLOATEventMetadata>():
                    return self.getEventMetadata()
            }

            return nil
        }

        init(_eventDescription: String, _eventHost: Address, _eventId: UInt64, _eventImage: String, _eventName: String, _originalRecipient: Address, _serial: UInt64) {
            self.id = self.uuid
            self.dateReceived = getCurrentBlock().timestamp
            self.eventDescription = _eventDescription
            self.eventHost = _eventHost
            self.eventId = _eventId
            self.eventImage = _eventImage
            self.eventName = _eventName
            self.originalRecipient = _originalRecipient
            self.serial = _serial

            self.eventsCap = getAccount(_eventHost)
                .getCapability<&FLOATEvents{FLOATEventsPublic, MetadataViews.ResolverCollection}>(FLOAT.FLOATEventsPublicPath)
            
            emit FLOATMinted(
                id: self.id, 
                eventHost: _eventHost, 
                eventId: _eventId, 
                eventImage: _eventImage,
                recipient: _originalRecipient,
                serial: _serial
            )

            FLOAT.totalSupply = FLOAT.totalSupply + 1
        }
    }

    pub resource interface CollectionPublic {
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
        pub fun borrowFLOAT(id: UInt64): &NFT?
        pub fun borrowViewResolver(id: UInt64): &{MetadataViews.Resolver}
        pub fun deposit(token: @NonFungibleToken.NFT)
        pub fun getIDs(): [UInt64]
        pub fun getAllIDs(): [UInt64]
        pub fun ownedIdsFromEvent(eventId: UInt64): [UInt64]
        pub fun ownedFLOATsFromEvent(eventId: UInt64): [&NFT]
    }

    // A Collection that holds all of the users FLOATs.
    // Withdrawing is not allowed. You can only transfer.
    pub resource Collection: NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection, CollectionPublic {
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}
        // Maps an eventId to the ids of FLOATs that this
        // this user owns from that event
        access(account) var events: {UInt64: {UInt64: Bool}}

        pub fun deposit(token: @NonFungibleToken.NFT) {
            let nft <- token as! @NFT
            let id = nft.id
            let eventId = nft.eventId
            emit Deposit(id: id, to: self.owner!.address)
            if self.events[eventId] == nil {
                self.events[eventId] = {id: true}
            } else {
                self.events[eventId]!.insert(key: id, true)
            }
            self.ownedNFTs[id] <-! nft
        }

        // Function is disabled, but here to fit the NonFungibleToken standard.
        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            pre {
                false: "The withdraw function is disabled on FLOAT."
            }
            return <- self.ownedNFTs.remove(key: 0)!
        }

        // Only works if the FLOAT Event the FLOAT is from
        // has transferring enabled.
        pub fun transfer(withdrawID: UInt64, recipient: &Collection{NonFungibleToken.CollectionPublic}) {
            let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("You do not own this FLOAT in your collection")
            let nft <- token as! @NFT
            
            let floatEvents: &FLOATEvents{FLOATEventsPublic} = nft.eventsCap.borrow() ?? panic("The FLOATEvent that this FLOAT came from has been unlinked.")
            let floatEvent: &FLOATEvent = floatEvents.borrowEventRef(eventId: nft.eventId)

            // Checks to see if this FLOAT is transferrable.
            assert(floatEvent.transferrable, message: "This FLOAT is not transferrable.")
            
            // Updates who the current holder is in the FLOATEvent.
            floatEvent.transferred(id: nft.id, serial: nft.serial, to: recipient.owner!.address)
            emit FLOATTransferred(id: nft.id, from: self.owner!.address, to: recipient.owner!.address, eventHost: nft.eventHost, eventId: nft.eventId, serial: nft.serial)

            self.events[nft.eventId]!.remove(key: nft.id)
            recipient.deposit(token: <- nft)
        }

        // Only returns the FLOATs for which we can still
        // access data about their event.
        pub fun getIDs(): [UInt64] {
            let ids: [UInt64] = []
            for key in self.ownedNFTs.keys {
                let tokenRef = &self.ownedNFTs[key] as auth &NonFungibleToken.NFT
                let nftRef = tokenRef as! &NFT
                if nftRef.eventsCap.check() {
                    ids.append(key)
                }
            }
            return ids
        }

        pub fun getAllIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        // Returns an array of ids that belong to
        // the passed in eventId
        pub fun ownedIdsFromEvent(eventId: UInt64): [UInt64] {
            if self.events[eventId] != nil {
                return self.events[eventId]!.keys
            }
            return []
        }

        // Returns an array of FLOATs that belong to
        // the passed in eventId
        pub fun ownedFLOATsFromEvent(eventId: UInt64): [&NFT] {
            let answer: [&NFT] = []
            let ids = self.ownedIdsFromEvent(eventId: eventId)
            for id in ids {
                answer.append(self.borrowFLOAT(id: id)!)
            }
            return answer
        }

        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return &self.ownedNFTs[id] as &NonFungibleToken.NFT
        }

        pub fun borrowFLOAT(id: UInt64): &NFT? {
            if self.ownedNFTs[id] != nil {
                let ref = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
                return ref as! &NFT
            }
            return nil
        }

        pub fun borrowViewResolver(id: UInt64): &{MetadataViews.Resolver} {
            let tokenRef = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
            let nftRef = tokenRef as! &NFT
            return nftRef as &{MetadataViews.Resolver}
        }

        // Since you can't withdraw FLOATs, this allows you
        // to delete a FLOAT if you wish.
        // The reason we don't put this logic inside the
        // destroy function is because we want to know
        // who the `lastOwner` is, and `self.owner!.address`
        // does not exist in the NFT resource when it's being
        // moved around.
        pub fun destroyFLOAT(id: UInt64) {
            let token <- self.ownedNFTs.remove(key: id) ?? panic("You do not own this FLOAT in your collection")
            let nft <- token as! @NFT

            // If the FLOATEvent owner decided to unlink their public reference
            // for some reason (heavily recommend against it), their records
            // of who owns the FLOAT is going to be messed up. But that is their
            // fault.
            if let floatEvents: &FLOATEvents{FLOATEventsPublic} = nft.eventsCap.borrow() {
                let floatEvent: &FLOATEvent = floatEvents.borrowEventRef(eventId: nft.eventId)
                floatEvent.accountDeletedFLOAT(serial: nft.serial)
            }
        
            emit FLOATDestroyed(
                id: nft.id, 
                eventHost: nft.eventHost, 
                eventId: nft.eventId, 
                serial: nft.serial,
                lastOwner: self.owner!.address
            )
            self.events[nft.eventId]!.remove(key: nft.id)
            destroy nft
        }

        init() {
            self.ownedNFTs <- {}
            self.events = {}
        }

        destroy() {
            pre {
                self.ownedNFTs.keys.length == 0: "You cannot delete a Collection with FLOATs inside of it."
            }
            destroy self.ownedNFTs
        }
    }

    pub struct interface IVerifier {
        // A function every verifier must implement. 
        // Will have `assert`s in it to make sure
        // the user fits some criteria.
        access(account) fun verify(_ params: {String: AnyStruct})
    }

    pub resource interface FLOATEventPublic {
        pub var claimable: Bool
        pub let dateCreated: UFix64
        pub let description: String 
        pub let eventId: UInt64
        pub let host: Address
        pub let image: String 
        pub let name: String
        pub var totalSupply: UInt64
        pub var transferrable: Bool
        pub let url: String
        pub fun getClaimed(): {Address: TokenIdentifier}
        pub fun getCurrentHolders(): {UInt64: TokenIdentifier}
        pub fun hasClaimed(account: Address): TokenIdentifier?
        pub fun getCurrentHolder(serial: UInt64): TokenIdentifier?
        pub fun claim(recipient: &Collection, params: {String: AnyStruct})
        pub fun getExtraMetadata(): {String: AnyStruct}
        pub fun getVerifiers(): {String: [{IVerifier}]}
        pub fun getGroups(): [String]
    }

    pub struct FLOATEventMetadata {
        pub let claimable: Bool
        pub let dateCreated: UFix64
        pub let description: String 
        pub let eventId: UInt64
        pub let extraMetadata: {String: String}
        pub let groups: [String]
        pub let host: Address
        pub let image: String 
        pub let name: String
        pub let totalSupply: UInt64
        pub let transferrable: Bool
        pub let url: String
        pub let verifiers: {String: [{IVerifier}]}

        init(
            _claimable: Bool,
            _dateCreated: UFix64,
            _description: String, 
            _eventId: UInt64,
            _extraMetadata: {String: String},
            _groups: [String],
            _host: Address, 
            _image: String, 
            _name: String,
            _totalSupply: UInt64,
            _transferrable: Bool,
            _url: String,
            _verifiers: {String: [{IVerifier}]}
        ) {
            self.claimable = _claimable
            self.dateCreated = _dateCreated
            self.description = _description
            self.eventId = _eventId
            self.extraMetadata = _extraMetadata
            self.groups = _groups
            self.host = _host
            self.image = _image
            self.name = _name
            self.transferrable = _transferrable
            self.totalSupply = _totalSupply
            self.url = _url
            self.verifiers = _verifiers
        }
    }

    pub struct FLOATEventHeavyMetadata {
        pub let claimed: {Address: TokenIdentifier}
        pub let currentHolders: {UInt64: TokenIdentifier}
        pub let metdata: FLOATEventMetadata

        init(
            _claimed: {Address: TokenIdentifier},
            _currentHolders: {UInt64: TokenIdentifier},
            _metadata: FLOATEventMetadata
        ) {
            self.claimed = _claimed
            self.currentHolders = _currentHolders
            self.metdata = _metadata
        }
    }

    //
    // FLOATEvent
    //
    pub resource FLOATEvent: FLOATEventPublic, MetadataViews.Resolver {
        pub var claimable: Bool
        // Maps an address to the FLOAT they claimed
        access(account) var claimed: {Address: TokenIdentifier}
        // Maps a serial to the person who theoretically owns
        // that FLOAT. Must be serial --> TokenIdentifier because
        // it's possible someone has multiple FLOATs from this event.
        access(account) var currentHolders: {UInt64: TokenIdentifier}
        pub let dateCreated: UFix64
        pub let description: String 
        pub let eventId: UInt64
        access(account) var extraMetadata: {String: String}
        access(account) var groups: {String: Bool}
        pub let host: Address
        pub let image: String 
        pub let name: String
        pub var totalSupply: UInt64
        pub var transferrable: Bool
        pub let url: String
        access(account) let verifiers: {String: [{IVerifier}]}

        /***************** Setters for the Event Owner *****************/

        // Toggles claiming on/off
        pub fun toggleClaimable(): Bool {
            self.claimable = !self.claimable
            return self.claimable
        }

        // Toggles transferring on/off
        pub fun toggleTransferrable(): Bool {
            self.transferrable = !self.transferrable
            return self.transferrable
        }

        // Updates the metadata in case you want
        // to add something. Not currently used for anything
        // on FLOAT, so it's empty.
        pub fun updateMetadata(newExtraMetadata: {String: String}) {
            self.extraMetadata = newExtraMetadata
        }

        /***************** Setters for the Contract Only *****************/

        // Called if a user transfers their FLOAT to another user.
        // Needed so we can keep track of who currently has it.
        access(account) fun transferred(id: UInt64, serial: UInt64, to: Address) {
            self.currentHolders[serial] = TokenIdentifier(
                _id: id,
                _address: to,
                _serial: serial
            )
        }

        // Called if a user deletes their FLOAT.
        // Removes the FLOAT's serial from the 
        // `currentHolders` dictionary.
        access(account) fun accountDeletedFLOAT(serial: UInt64) {
            self.currentHolders.remove(key: serial)
        }

        access(account) fun addToGroup(groupName: String) {
            self.groups[groupName] = true
        }

        access(account) fun removeFromGroup(groupName: String) {
            self.groups.remove(key: groupName)
        }

        /***************** Getters (all exposed to the public) *****************/

        pub fun hasClaimed(account: Address): TokenIdentifier? {
            return self.claimed[account]
        }

        // This is a guarantee that the person owns the FLOAT
        pub fun getCurrentHolder(serial: UInt64): TokenIdentifier? {
            if let data = self.currentHolders[serial] {
                if let collection = getAccount(data.address).getCapability(FLOAT.FLOATCollectionPublicPath).borrow<&Collection{CollectionPublic}>() {
                    if collection.borrowFLOAT(id: data.id) != nil {
                        return data
                    }
                }
            }
            
            return nil
        }

        pub fun getClaimed(): {Address: TokenIdentifier} {
            return self.claimed
        }

        // This dictionary may be slightly off if for some
        // reason the FLOATEvents owner ever unlinked their
        // resource from the public.  
        // Use `getCurrentHolder(serial: UInt64)` to truly
        // verify if someone holds that serial.
        pub fun getCurrentHolders(): {UInt64: TokenIdentifier} {
            return self.currentHolders
        }

        pub fun getExtraMetadata(): {String: AnyStruct} {
            return self.extraMetadata
        }

        pub fun getVerifiers(): {String: [{IVerifier}]} {
            return self.verifiers
        }

        pub fun getGroups(): [String] {
            return self.groups.keys
        }

        pub fun getViews(): [Type] {
             return [
                Type<MetadataViews.Display>(),
                Type<FLOATEventMetadata>(),
                Type<FLOATEventHeavyMetadata>()
            ]
        }

        pub fun resolveView(_ view: Type): AnyStruct? {
            switch view {
                case Type<MetadataViews.Display>():
                    return MetadataViews.Display(
                        name: self.name, 
                        description: self.description, 
                        file: MetadataViews.IPFSFile(cid: self.image, path: nil)
                    )
                case Type<FLOATEventMetadata>():
                    return FLOATEventMetadata(
                        _claimable: self.claimable,
                        _dateCreated: self.dateCreated,
                        _description: self.description, 
                        _eventId: self.eventId,
                        _extraMetadata: self.extraMetadata,
                        _groups: self.groups.keys,
                        _host: self.host, 
                        _image: self.image, 
                        _name: self.name,
                        _totalSupply: self.totalSupply,
                        _transferrable: self.transferrable,
                        _url: self.url,
                        _verifiers: self.verifiers
                    )
                case Type<FLOATEventHeavyMetadata>():
                    return FLOATEventHeavyMetadata(
                        _claimed: self.claimed,
                        _currentHolders: self.currentHolders,
                        _metadata: self.resolveView(Type<FLOATEventMetadata>())! as! FLOATEventMetadata
                    )
            }

            return nil
        }

        /****************** Getting a FLOAT ******************/

        // Used to give a person a FLOAT from this event.
        // Used as a helper function for `claim`, but can also be 
        // used by the event owner and shared accounts to
        // mint directly to a user.
        //
        // Return the id of the FLOAT it minted
        pub fun mint(recipient: &Collection{NonFungibleToken.CollectionPublic}): UInt64 {
            pre {
                self.claimed[recipient.owner!.address] == nil:
                    "This person already claimed their FLOAT!"
            }
            let recipientAddr: Address = recipient.owner!.address
            let serial = self.totalSupply

            let token <- create NFT(
                _eventDescription: self.description,
                _eventHost: self.host, 
                _eventId: self.eventId,
                _eventImage: self.image,
                _eventName: self.name,
                _originalRecipient: recipientAddr, 
                _serial: serial
            ) 
            let id = token.id
            self.claimed[recipientAddr] = TokenIdentifier(
                _id: id,
                _address: recipientAddr,
                _serial: serial
            )
            self.currentHolders[serial] = TokenIdentifier(
                _id: id,
                _address: recipientAddr,
                _serial: serial
            )

            self.totalSupply = self.totalSupply + 1
            recipient.deposit(token: <- token)
            return id
        }

        // For the public to claim FLOATs. Must be claimable to do so.
        // You can pass in `params` that will be forwarded to the
        // customized `verify` function of the verifier.  
        //
        // For example, the FLOAT platform allows event hosts
        // to specify a secret phrase. That secret phrase will 
        // be passed in the `params`.
        pub fun claim(recipient: &Collection, params: {String: AnyStruct}) {
            pre {
                self.claimable: 
                    "This FLOATEvent is not claimable, and thus not currently active."
            }
            
            params["event"] = self.resolveView(Type<FLOATEventMetadata>())! as! FLOATEventMetadata
            params["claimee"] = recipient.owner!.address
            
            for identifier in self.verifiers.keys {
                let typedModules = &self.verifiers[identifier] as &[{IVerifier}]
                var i = 0
                while i < typedModules.length {
                    let verifier = &typedModules[i] as &{IVerifier}
                    verifier.verify(params)
                    i = i + 1
                }
            }

            // You're good to go.
            let id = self.mint(recipient: recipient)

            emit FLOATClaimed(
                id: id,
                eventHost: self.host, 
                eventId: self.eventId, 
                eventImage: self.image,
                eventName: self.name,
                recipient: recipient.owner!.address,
                serial: self.totalSupply - 1
            )
        }

        init (
            _claimable: Bool,
            _description: String, 
            _extraMetadata: {String: String},
            _host: Address, 
            _image: String, 
            _name: String,
            _transferrable: Bool,
            _url: String,
            _verifiers: {String: [{IVerifier}]},
        ) {
            self.claimable = _claimable
            self.claimed = {}
            self.currentHolders = {}
            self.dateCreated = getCurrentBlock().timestamp
            self.description = _description
            self.eventId = self.uuid
            self.extraMetadata = _extraMetadata
            self.groups = {}
            self.host = _host
            self.image = _image
            self.name = _name
            self.transferrable = _transferrable
            self.totalSupply = 0
            self.url = _url
            
            self.verifiers = _verifiers

            FLOAT.totalFLOATEvents = FLOAT.totalFLOATEvents + 1
            emit FLOATEventCreated(eventId: self.eventId, description: self.description, host: self.host, image: self.image, name: self.name, url: self.url)
        }

        // There must be 0 existing FLOATs from this event
        // in order to delete it. This means people who have
        // the FLOATs can technically delete all of them
        // in order for the event host to delete this event.
        // This event must also not belong to any groups.
        destroy() {
            pre {
                self.totalSupply == 0:
                    "You cannot delete this event because some FLOATs still exist from this event."
            }
            emit FLOATEventDestroyed(eventId: self.eventId, host: self.host, name: self.name)
        }
    }

    pub struct Group {
        pub let name: String
        pub let image: String
        pub let description: String
        access(account) var events: {UInt64: Bool}

        access(account) fun addEvent(eventId: UInt64) {
            self.events[eventId] = true
        }

        access(account) fun removeEvent(eventId: UInt64) {
            self.events.remove(key: eventId)
        }

        pub fun getEvents(): [UInt64] {
            return self.events.keys
        }

        init(_name: String, _image: String, _description: String) {
            self.name = _name
            self.image = _image
            self.description = _description
            self.events = {}
        }
    }
 
    // 
    // FLOATEvents
    //
    pub resource interface FLOATEventsPublic {
        // Public Getters
        pub fun borrowSharedRef(fromHost: Address): &FLOATEvents
        pub fun borrowPublicEventRef(eventId: UInt64): &FLOATEvent{FLOATEventPublic}
        pub fun getAllEvents(): {UInt64: String}
        pub fun getIDs(): [UInt64]
        pub fun getGroup(groupName: String): Group?
        pub fun getGroups(): [String]
        // Account Getters
        access(account) fun borrowEventRef(eventId: UInt64): &FLOATEvent
        access(account) fun borrowEventsRef(): &FLOATEvents
    }

    pub resource FLOATEvents: FLOATEventsPublic, MetadataViews.ResolverCollection {
        access(account) var events: @{UInt64: FLOATEvent}
        access(account) var groups: {String: Group}

        pub fun createEvent(
            claimable: Bool,
            description: String,
            image: String, 
            name: String, 
            transferrable: Bool,
            url: String,
            verifiers: [{IVerifier}],
            _ extraMetadata: {String: String}
        ): UInt64 {
            let typedVerifiers: {String: [{IVerifier}]} = {}
            for verifier in verifiers {
                let identifier = verifier.getType().identifier
                if typedVerifiers[identifier] == nil {
                    typedVerifiers[identifier] = [verifier]
                } else {
                    typedVerifiers[identifier]!.append(verifier)
                }
            }

            let FLOATEvent <- create FLOATEvent(
                _claimable: claimable,
                _description: description, 
                _extraMetadata: extraMetadata,
                _host: self.owner!.address, 
                _image: image, 
                _name: name, 
                _transferrable: transferrable,
                _url: url,
                _verifiers: typedVerifiers
            )
            let eventId = FLOATEvent.eventId
            self.events[FLOATEvent.eventId] <-! FLOATEvent
            return eventId
        }

        // Delete an event if you made a mistake.
        // You can only delete an event if 0 people
        // are currently holding that FLOAT and
        // it does not belong to any groups, as written in the
        // destroy() function of the FLOATEvent resource.
        pub fun deleteEvent(eventId: UInt64) {
            let event <- self.events.remove(key: eventId) ?? panic("This event does not exist")
            for groupName in event.getGroups() {
                let groupRef = &self.groups[groupName] as &Group 
                groupRef.removeEvent(eventId: eventId)
            }
            destroy event
        }

        pub fun createGroup(groupName: String, image: String, description: String) {
            pre {
                self.groups[groupName] == nil: "A group with this name already exists."
            }
            self.groups[groupName] = Group(_name: groupName, _image: image, _description: description)
        }

        pub fun deleteGroup(groupName: String) {
            let eventsInGroup = self.groups[groupName]?.getEvents() 
                                ?? panic("This Group does not exist.")
            for eventId in eventsInGroup {
                let ref = &self.events[eventId] as &FLOATEvent
                ref.removeFromGroup(groupName: groupName)
            }
            self.groups.remove(key: groupName)
        }

        pub fun addEventToGroup(groupName: String, eventId: UInt64) {
            pre {
                self.groups[groupName] != nil: "This group does not exist."
            }
            let groupRef = &self.groups[groupName] as &Group
            groupRef.addEvent(eventId: eventId)

            let eventRef = self.borrowEventRef(eventId: eventId)
            eventRef.addToGroup(groupName: groupName)
        }

        pub fun removeEventFromGroup(groupName: String, eventId: UInt64) {
            pre {
                self.groups[groupName] != nil: "This group does not exist."
            }
            let groupRef = &self.groups[groupName] as &Group
            groupRef.removeEvent(eventId: eventId)

            let eventRef = self.borrowEventRef(eventId: eventId)
            eventRef.removeFromGroup(groupName: groupName)
        }

        pub fun getGroup(groupName: String): Group? {
            return self.groups[groupName]
        }
        
        pub fun getGroups(): [String] {
            return self.groups.keys
        }

        // Only accessible to people who share your account
        pub fun borrowSharedRef(fromHost: Address): &FLOATEvents {
            let sharedInfo = getAccount(fromHost).getCapability(SharedAccount.InfoPublicPath)
                                .borrow<&SharedAccount.Info{SharedAccount.InfoPublic}>() 
                                ?? panic("Cannot borrow the InfoPublic from the host")
            assert(
                sharedInfo.isAllowed(account: self.owner!.address),
                message: "This account owner does not share their account with you."
            )
            let otherFLOATEvents = getAccount(fromHost).getCapability(FLOAT.FLOATEventsPublicPath)
                                    .borrow<&FLOATEvents{FLOATEventsPublic}>()
                                    ?? panic("Could not borrow the public FLOATEvents.")
            return otherFLOATEvents.borrowEventsRef()
        }

        // Only used for the above function.
        access(account) fun borrowEventsRef(): &FLOATEvents {
            return &self as &FLOATEvents
        }

        pub fun borrowEventRef(eventId: UInt64): &FLOATEvent {
            return &self.events[eventId] as &FLOATEvent
        }

        /************* Getters (for anyone) *************/

        // Get a public reference to the FLOATEvent
        // so you can call some helpful getters
        pub fun borrowPublicEventRef(eventId: UInt64): &FLOATEvent{FLOATEventPublic} {
            return &self.events[eventId] as &FLOATEvent{FLOATEventPublic}
        }

        pub fun getIDs(): [UInt64] {
            return self.events.keys
        }

        pub fun getAllEvents(): {UInt64: String} {
            let answer: {UInt64: String} = {}
            for id in self.events.keys {
                let ref = &self.events[id] as &FLOATEvent
                answer[id] = ref.name
            }
            return answer
        }

        pub fun borrowViewResolver(id: UInt64): &{MetadataViews.Resolver} {
            return &self.events[id] as &{MetadataViews.Resolver}
        }

        init() {
            self.events <- {}
            self.groups = {}
        }

        destroy() {
            destroy self.events
        }
    }

    pub fun createEmptyCollection(): @Collection {
        return <- create Collection()
    }

    pub fun createEmptyFLOATEventCollection(): @FLOATEvents {
        return <- create FLOATEvents()
    }

    init() {
        self.totalSupply = 0
        self.totalFLOATEvents = 0
        emit ContractInitialized()

        self.FLOATCollectionStoragePath = /storage/FLOATCollectionStoragePath042
        self.FLOATCollectionPublicPath = /public/FLOATCollectionPublicPath042
        self.FLOATEventsStoragePath = /storage/FLOATEventsStoragePath042
        self.FLOATEventsPrivatePath = /private/FLOATEventsPrivatePath042
        self.FLOATEventsPublicPath = /public/FLOATEventsPublicPath042
    }
}