import NonFungibleToken from "./core-contracts/NonFungibleToken.cdc"
import MetadataViews from "./core-contracts/MetadataViews.cdc"

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
    pub event FLOATDeposited(id: UInt64, to: Address)
    pub event FLOATDestroyed(id: UInt64, eventHost: Address, eventId: UInt64, serial: UInt64)
    pub event FLOATTransferred(id: UInt64, from: Address, to: Address, eventHost: Address, eventId: UInt64, serial: UInt64)
    pub event FLOATEventCreated(eventId: UInt64, description: String, host: Address, image: String, name: String, url: String)
    pub event FLOATEventCreatedBySharedMinter(forHost: Address, bySharedMinter: Address, eventId: UInt64)
    pub event FLOATEventDestroyed(eventId: UInt64, host: Address, name: String)

    // Throw away for standard. These are not used.
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id: UInt64, to: Address?)

    /***********************************************/
    /******************** STATE ********************/
    /***********************************************/

    pub var totalSupply: UInt64
    pub var totalFLOATEvents: UInt64

    /***********************************************/
    /**************** FUNCTIONALITY ****************/
    /***********************************************/

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

    pub struct FLOATMetadata {
        pub let id: UInt64
        pub let dateReceived: UFix64
        pub let eventDescription: String
        pub let eventHost: Address
        pub let eventId: UInt64
        pub let eventImage: String
        pub let eventName: String
        pub let originalRecipient: Address
        pub let owner: Address
        pub let serial: UInt64

        init(
            _id: UInt64,
            _dateReceived: UFix64, 
            _eventDescription: String,
            _eventHost: Address, 
            _eventId: UInt64,
            _eventImage: String,
            _eventName: String,
            _originalRecipient: Address,
            _owner: Address,
            _serial: UInt64
        ) {
            self.id = _id
            self.dateReceived = _dateReceived
            self.eventDescription = _eventDescription
            self.eventHost = _eventHost
            self.eventId = _eventId
            self.eventImage = _eventImage
            self.eventName = _eventName
            self.originalRecipient = _originalRecipient
            self.owner = _owner
            self.serial = _serial
        }
    }

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

        // A capability that points to metadata about the FLOAT event
        // this FLOAT is from.
        // There is a chance the event host unlinks their event from
        // the public, in which case it's impossible to know details
        // about the event. 
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
                Type<FLOATMetadata>(),
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
                case Type<FLOATMetadata>():
                    return FLOATMetadata(
                        _id: self.id,
                        _dateReceived: self.dateReceived, 
                        _eventDescription: self.eventDescription,
                        _eventHost: self.eventHost, 
                        _eventId: self.eventId,
                        _eventImage: self.eventImage,
                        _eventName: self.eventName,
                        _originalRecipient: self.originalRecipient,
                        _owner: self.owner!.address,
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

        // When destroyed, we make sure to update the FLOAT Event metadata.
        // Sspecifically, to remove this user as a current holder of this FLOAT).
        // Note that if the event owner unlinks their FLOATEVents from the public
        // for some reason, it is impossible to destroy this FLOAT.
        destroy() {
            let floatEvents: &FLOATEvents{FLOATEventsPublic} = self.eventsCap.borrow() 
                ?? panic("This Event Collection this FLOAT came from has been deleted.")
            let floatEvent: &FLOATEvent = floatEvents.borrowEventRef(eventId: self.eventId)
            floatEvent.accountDeletedFLOAT(serial: self.serial)
            emit FLOATDestroyed(
                id: self.id, 
                eventHost: self.eventHost, 
                eventId: self.eventId, 
                serial: self.serial
            )
        }
    }

    // A collectiont that holds all of the users FLOATs.
    // Withdrawing is not allowed. You can only transfer.
    pub resource Collection: NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection {
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

        pub fun deposit(token: @NonFungibleToken.NFT) {
            let nft <- token as! @NFT
            emit FLOATDeposited(id: nft.id, to: self.owner!.address)
            self.ownedNFTs[nft.id] <-! nft
        }

        // Function is disabled, but here to fit the NonFungibleToken standard.
        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            pre {
                false: "The withdraw function is disabled on FLOAT."
            }
            return <- self.ownedNFTs.remove(key: 0)!
        }

        // Only works if the FLOAT Event has transferring enabled.
        pub fun transfer(withdrawID: UInt64, recipient: &Collection{NonFungibleToken.CollectionPublic}) {
            let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("You do not own this FLOAT in your collection")
            let nft <- token as! @NFT
            
            let floatEvents: &FLOATEvents{FLOATEventsPublic} = nft.eventsCap.borrow() ?? panic("This Event Collection this FLOAT came from has been deleted.")
            let floatEvent: &FLOATEvent = floatEvents.borrowEventRef(eventId: nft.eventId)

            // Checks to see if this FLOAT is transferrable.
            assert(floatEvent.transferrable, message: "This FLOAT is not transferrable.")
            
            // Updates who the current holder is in the FLOATEvent.
            floatEvent.transferred(id: nft.id, serial: nft.serial, to: recipient.owner!.address)
            emit FLOATTransferred(id: nft.id, from: self.owner!.address, to: recipient.owner!.address, eventHost: nft.eventHost, eventId: nft.eventId, serial: nft.serial)

            recipient.deposit(token: <- nft)
        }

        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return &self.ownedNFTs[id] as &NonFungibleToken.NFT
        }

        pub fun borrowViewResolver(id: UInt64): &{MetadataViews.Resolver} {
            let tokenRef = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
            let nftRef = tokenRef as! &NFT
            return nftRef as &{MetadataViews.Resolver}
        }

        // Since you can't withdraw FLOATs, this allows you
        // to delete a FLOAT if you wish.
        pub fun destroyFLOAT(id: UInt64) {
            let token <- self.ownedNFTs.remove(key: id) ?? panic("You do not own this FLOAT in your collection")
            let nft <- token as! @NFT
            destroy nft
        }

        init() {
            self.ownedNFTs <- {}
        }

        destroy() {
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
        pub fun getClaimed(): {Address: TokenIdentifier}
        pub fun getCurrentHolders(): {UInt64: TokenIdentifier}
        pub fun hasClaimed(account: Address): TokenIdentifier?
        pub fun getCurrentHolder(serial: UInt64): TokenIdentifier?
        pub fun claim(recipient: &Collection, params: {String: AnyStruct})
    }

    pub struct FLOATEventMetadata {
        pub let claimable: Bool
        pub let dateCreated: UFix64
        pub let description: String 
        pub let eventId: UInt64
        pub let extraMetadata: {String: String}
        pub let host: Address
        pub let image: String 
        pub let name: String
        pub let totalSupply: UInt64
        pub let transferrable: Bool
        pub let url: String
        pub let verifiers: {String: [{IVerifier}]}

        init(
            _claimable: Bool,
            _description: String, 
            _eventId: UInt64,
            _extraMetadata: {String: String},
            _host: Address, 
            _image: String, 
            _name: String,
            _totalSupply: UInt64,
            _transferrable: Bool,
            _url: String,
            _verifiers: {String: [{IVerifier}]}
        ) {
            self.claimable = _claimable
            self.dateCreated = getCurrentBlock().timestamp
            self.description = _description
            self.eventId = _eventId
            self.extraMetadata = _extraMetadata
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
        access(account) var claimed: {Address: TokenIdentifier}
        access(account) var currentHolders: {UInt64: TokenIdentifier}
        pub let dateCreated: UFix64
        pub let description: String 
        pub let eventId: UInt64
        access(account) var extraMetadata: {String: String}
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
        // Needed so we can keep track of who currently has it
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

        /***************** Getters (all exposed to the public) *****************/

        pub fun hasClaimed(account: Address): TokenIdentifier? {
            return self.claimed[account]
        }

        pub fun getCurrentHolder(serial: UInt64): TokenIdentifier? {
            return self.currentHolders[serial]
        }

        pub fun getClaimed(): {Address: TokenIdentifier} {
            return self.claimed
        }

        pub fun getCurrentHolders(): {UInt64: TokenIdentifier} {
            return self.currentHolders
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
                        _description: self.description, 
                        _eventId: self.eventId,
                        _extraMetadata: self.extraMetadata,
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
        // used by the event owner and shared minters to
        // mint directly.
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
        // For example, the FLOAT platfrom allows event hosts
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
                serial: self.totalSupply
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
        destroy() {
            pre {
                self.currentHolders.keys.length == 0:
                    "You cannot delete this event because some FLOATs still exist from this event."
            }
            emit FLOATEventDestroyed(eventId: self.eventId, host: self.host, name: self.name)
        }
    }
 
    // 
    // FLOATEvents
    //
    pub resource interface FLOATEventsPublic {
        // Public Getters
        pub var sharedMinting: Bool
        pub fun borrowPublicEventRef(eventId: UInt64): &FLOATEvent{FLOATEventPublic}
        pub fun getAllEvents(): {UInt64: String}
        pub fun getAddressWhoICanMintFor(): [Address]
        pub fun getAddressWhoCanMintForMe(): [Address]
        pub fun getIDs(): [UInt64]
        pub fun isSharedMinterFor(host: Address): Bool
        // Account Setters
        access(account) fun createEvent(claimable: Bool, description: String, image: String, name: String, transferrable: Bool, url: String, verifiers: [{IVerifier}], _ extraMetadata: {String: String}): UInt64
        access(account) fun receiveSharing(fromHost: Address) 
        access(account) fun removeSharing(ofHost: Address)
        // Account Getters
        access(account) fun borrowEventRef(eventId: UInt64): &FLOATEvent
    }

    pub resource FLOATEvents: FLOATEventsPublic, MetadataViews.ResolverCollection {
        access(account) var events: @{UInt64: FLOATEvent}
        // A list of accounts you can mint for
        access(account) var canMintForThem: {Address: Bool}
        // A list of accounts you are allowing to mint for you
        access(account) var canMintForMe: {Address: Bool}
        pub var sharedMinting: Bool

        // ACCESSIBLE BY: Owner
        // Create a new FLOAT Event.
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

        // ACCESSIBLE BY: Owner
        //
        // Delete an event if you made a mistake.
        // You can only delete an event if 0 people
        // are currently holding that FLOAT, as written in the
        // destroy() function of the FLOATEvent resource.
        pub fun deleteEvent(eventId: UInt64) {
            let event <- self.events.remove(key: eventId) ?? panic("This event does not exist")
            destroy event
        }

        // ACCESSIBLE BY: Owner, Contract
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

        /************* Functionality for Shared Minters *************/

        // ACCESSIBLE BY: Contract
        // A method for getting access to a shared minter. This is if 
        // a different account wants you to be able to handle their FLOAT Events
        // for them, so imagine if you're on a team of people and you all handle
        // one account.
        //
        // Will only be called by `giveSharing` below.
        access(account) fun receiveSharing(fromHost: Address) {
            // Allows you to mint for them
            self.canMintForThem.insert(key: fromHost, true)
        }

        // ACCESSIBLE BY: Owner
        // A method for giving a shared minter to somebody else.
        pub fun giveSharing(toHost: &FLOATEvents{FLOATEventsPublic}) {
            // Gives `toHost` the ability to mint for you
            toHost.receiveSharing(fromHost: self.owner!.address)
            self.canMintForMe.insert(key: toHost.owner!.address, true)
        }

        // ACCESSIBLE BY: Owner, Contract
        pub fun removeSharing(ofHost: Address) {
            self.canMintForThem.remove(key: ofHost)
        }

        // ACCESSIBLE BY: Owner
        // Removes someone else from being able to handle your FLOAT Events.
        pub fun takeSharing(fromHost: Address) {
            // If for some reason they unlink their Collection from the public,
            // we can still remove them from ours.
            if let fromHostEvents = getAccount(fromHost).getCapability(FLOAT.FLOATEventsPublicPath).borrow<&FLOATEvents{FLOATEventsPublic}>() {
                fromHostEvents.removeSharing(ofHost: self.owner!.address)
            }
            self.canMintForMe.remove(key: fromHost)
        }

        // ACCESSIBLE BY: All
        // Allows you to try and create an event
        // for another account.
        pub fun createEventSharedMinter(
            forHost: Address,
            claimable: Bool,
            description: String,
            image: String, 
            name: String, 
            transferrable: Bool,
            url: String,
            verifiers: [{IVerifier}],
            _ extraMetadata: {String: String}
        ) {
            let floatEvents = getAccount(forHost).getCapability(FLOAT.FLOATEventsPublicPath)
                                .borrow<&FLOATEvents{FLOATEventsPublic}>() 
                                ?? panic("Cannot borrow the public FLOAT Events from forHost")
            self.isSharedMinterFor(host: forHost)
            let eventId = floatEvents.createEvent(claimable: claimable, description: description, image: image, name: name, transferrable: transferrable, url: url, verifiers: verifiers, extraMetadata)
            emit FLOATEventCreatedBySharedMinter(forHost: forHost, bySharedMinter: self.owner!.address, eventId: eventId)
        }

        pub fun mintSharedMinter(
            forHost: Address, 
            eventId: UInt64, 
            recipient: &Collection{NonFungibleToken.CollectionPublic}
        ) {
            let floatEvents = getAccount(forHost).getCapability(FLOAT.FLOATEventsPublicPath)
                                .borrow<&FLOATEvents{FLOATEventsPublic}>() 
                                ?? panic("Cannot borrow the public FLOAT Events from forHost")
            assert(self.isSharedMinterFor(host: forHost), message: "You cannot mint for this host.")
            let floatEvent: &FLOATEvent = floatEvents.borrowEventRef(eventId: eventId)
            floatEvent.mint(recipient: recipient)
        }

        pub fun isSharedMinterFor(host: Address): Bool {
            let floatEvents = getAccount(host).getCapability(FLOAT.FLOATEventsPublicPath)
                                .borrow<&FLOATEvents{FLOATEventsPublic}>() 
                                ?? panic("Cannot borrow the public FLOAT Events from forHost")
            // you MUST check the other host's "canMintForMe"
            // This is confusing, but basically it's possible
            // for the canMintForMe and canMintForThem to be
            // out of sync
            return floatEvents.sharedMinting && floatEvents.getAddressWhoCanMintForMe().contains(self.owner!.address)
        }

        // ACCESSIBLE BY: Owner
        pub fun toggleSharedMinting(): Bool {
            self.sharedMinting = !self.sharedMinting
            return self.sharedMinting
        }

        // ACCESSIBLE BY: All
        // Get a list of accounts you have
        // access to.
        pub fun getAddressWhoICanMintFor(): [Address] {
            return self.canMintForThem.keys
        }

        // ACCESSIBLE BY: All
        // Get a list of accounts you have allowed
        // to mint for you.
        pub fun getAddressWhoCanMintForMe(): [Address] {
            return self.canMintForMe.keys
        }

        init() {
            self.events <- {}
            self.canMintForThem = {}
            self.canMintForMe = {}
            self.sharedMinting = true
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

        self.FLOATCollectionStoragePath = /storage/FLOATCollectionStoragePath032
        self.FLOATCollectionPublicPath = /public/FLOATCollectionPublicPath032
        self.FLOATEventsStoragePath = /storage/FLOATEventsStoragePath032
        self.FLOATEventsPrivatePath = /private/FLOATEventsPrivatePath032
        self.FLOATEventsPublicPath = /public/FLOATEventsPublicPath032
    }
}