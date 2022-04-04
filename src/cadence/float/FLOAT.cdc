// MADE BY: Emerald City, Jacob Tucker

// This contract is for FLOAT, a proof of participation platform
// on Flow. It is similar to POAP, but a lot, lot cooler. ;)

// The main idea is that FLOATs are simply NFTs. They are minted from
// a FLOATEvent, which is basically an event that a host starts. For example,
// if I have a Twitter space and want to create an event for it, I can create
// a new FLOATEvent in my FLOATEvents collection and mint FLOATs to people
// from this Twitter space event representing that they were there.  

// The complicated part is the FLOATVerifiers contract. That contract 
// defines a list of "verifiers" that can be tagged onto a FLOATEvent to make
// the claiming more secure. For example, a host can decide to put a time 
// constraint on when users can claim a FLOAT. They would do that by passing in
// a Timelock struct (defined in FLOATVerifiers.cdc) with a time period for which
// users can claim. 

// For a whole list of verifiers, see FLOATVerifiers.cdc 

// Lastly, we implemented GrantedAccountAccess.cdc, which allows you to specify
// someone else can control your account (in the context of FLOAT). This 
// is specifically designed for teams to be able to handle one "host" on the
// FLOAT platform so all the company's events are under one account.
// This is mainly used to give other people access to your FLOATEvents resource,
// and allow them to mint for you and control Admin operations on your events.  

// For more info on GrantedAccountAccess, see GrantedAccountAccess.cdc

import NonFungibleToken from 0x1d7e57aa55817448
import MetadataViews from 0x1d7e57aa55817448
import GrantedAccountAccess from 0x2d4c3caffbeab845

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
    pub event FLOATEventDestroyed(eventId: UInt64, host: Address, name: String)

    pub event Deposit(id: UInt64, to: Address?)
    // Throw away for standard
    pub event Withdraw(id: UInt64, from: Address?)

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

        // Some of these are also duplicated on the event,
        // but it's necessary to put them here as well
        // in case the FLOATEvent host deletes the event
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
        pub fun getEventMetadata(): &FLOATEvent{FLOATEventPublic}? {
            if let events = self.eventsCap.borrow() {
                return events.borrowPublicEventRef(eventId: self.eventId)
            }
            return nil
        }

        // This is for the MetdataStandard
        pub fun getViews(): [Type] {
             return [
                Type<MetadataViews.Display>(),
                Type<TokenIdentifier>()
            ]
        }

        // This is for the MetdataStandard
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

            // Stores a capability to the FLOATEvents of its creator
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

    // A public interface for people to call into our Collection
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
        // Maps a FLOAT id to the FLOAT itself
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}
        // Maps an eventId to the ids of FLOATs that
        // this user owns from that event
        access(account) var events: {UInt64: {UInt64: Bool}}

        // Deposits a FLOAT to the collection
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
            
            let floatEvent: &FLOATEvent{FLOATEventPublic} = nft.getEventMetadata() ?? panic("The FLOAT Evemt host unlinked their FLOAT Events")

            // Checks to see if this FLOAT is transferrable.
            assert(floatEvent.transferrable, message: "This FLOAT is not transferrable.")
            
            // Updates who the current holder is in the FLOATEvent.
            floatEvent.transferred(id: nft.id, serial: nft.serial, to: recipient.owner!.address)
            emit FLOATTransferred(id: nft.id, from: self.owner!.address, to: recipient.owner!.address, eventHost: nft.eventHost, eventId: nft.eventId, serial: nft.serial)

            self.events[nft.eventId]!.remove(key: nft.id)

            // Transfers the FLOAT
            recipient.deposit(token: <- nft)
        }

        // Only returns the FLOATs for which we can still
        // access data about their event.
        pub fun getIDs(): [UInt64] {
            let ids: [UInt64] = []
            for key in self.ownedNFTs.keys {
                let nftRef = self.borrowFLOAT(id: key)!
                if nftRef.eventsCap.check() {
                    ids.append(key)
                }
            }
            return ids
        }

        // Returns all the FLOATs ids
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
        // moved around (aka destroyed).
        pub fun destroyFLOAT(id: UInt64) {
            let token <- self.ownedNFTs.remove(key: id) ?? panic("You do not own this FLOAT in your collection")
            let nft <- token as! @NFT

            // If the FLOATEvent owner decided to unlink their public reference
            // for some reason (heavily recommend against it), their records
            // of who owns the FLOAT is going to be messed up. But that is their
            // fault. We shouldn't let that prevent the user from deleting the FLOAT.
            if let floatEvent: &FLOATEvent{FLOATEventPublic} = nft.getEventMetadata() {
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
            for id in self.getIDs() {
                self.destroyFLOAT(id: id)
            }
            destroy self.ownedNFTs
        }
    }

    // An interface that every "verifier" must implement. 
    // A verifier is one of the options on the FLOAT Event page,
    // for example, a "time limit," or a "limited" number of 
    // FLOATs that can be claimed. 
    // All the current verifiers can be seen inside FLOATVerifiers.cdc
    pub struct interface IVerifier {
        // A function every verifier must implement. 
        // Will have `assert`s in it to make sure
        // the user fits some criteria.
        access(account) fun verify(_ params: {String: AnyStruct})
    }

    // A public interface to read the FLOATEvent
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
        pub fun claim(recipient: &Collection, params: {String: AnyStruct})
        pub fun getClaimed(): {Address: TokenIdentifier}
        pub fun getCurrentHolders(): {UInt64: TokenIdentifier}
        pub fun getCurrentHolder(serial: UInt64): TokenIdentifier?
        pub fun getExtraMetadata(): {String: AnyStruct}
        pub fun getVerifiers(): {String: [{IVerifier}]}
        pub fun getGroups(): [String]
        pub fun hasClaimed(account: Address): TokenIdentifier?

        access(account) fun accountDeletedFLOAT(serial: UInt64)
        access(account) fun transferred(id: UInt64, serial: UInt64, to: Address)
    }

    //
    // FLOATEvent
    //
    pub resource FLOATEvent: FLOATEventPublic, MetadataViews.Resolver {
        // Whether or not users can claim from our event (can be toggled
        // at any time)
        pub var claimable: Bool
        // Maps an address to the FLOAT they claimed
        access(account) var claimed: {Address: TokenIdentifier}
        // Maps a serial to the person who theoretically owns
        // that FLOAT. Must be serial --> TokenIdentifier because
        // it's possible someone has multiple FLOATs from this event.
        access(account) var currentHolders: {UInt64: TokenIdentifier}
        pub let dateCreated: UFix64
        pub let description: String 
        // This is equal to this resource's uuid
        pub let eventId: UInt64
        access(account) var extraMetadata: {String: AnyStruct}
        // The groups that this FLOAT Event belongs to (groups
        // are within the FLOATEvents resource)
        access(account) var groups: {String: Bool}
        // Who created this FLOAT Event
        pub let host: Address
        // The image of the FLOAT Event
        pub let image: String 
        // The name of the FLOAT Event
        pub let name: String
        // The total number of FLOATs that have been
        // minted from this event
        pub var totalSupply: UInt64
        // Whether or not the FLOATs that users own
        // from this event can be transferred (can be
        // toggled at any point)
        pub var transferrable: Bool
        // A url of where the event took place
        pub let url: String
        // A list of verifiers this FLOAT Event contains.
        // Will be used every time someone "claims" a FLOAT
        // to see if they pass the requirements
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
        pub fun updateMetadata(newExtraMetadata: {String: AnyStruct}) {
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

        // Adds this FLOAT Event to a group
        access(account) fun addToGroup(groupName: String) {
            self.groups[groupName] = true
        }

        // Removes this FLOAT Event to a group
        access(account) fun removeFromGroup(groupName: String) {
            self.groups.remove(key: groupName)
        }

        /***************** Getters (all exposed to the public) *****************/

        // Returns info about the FLOAT that this account claimed
        // (if any)
        pub fun hasClaimed(account: Address): TokenIdentifier? {
            return self.claimed[account]
        }

        // This is a guarantee that the person owns the FLOAT
        // with the passed in serial
        pub fun getCurrentHolder(serial: UInt64): TokenIdentifier? {
            pre {
                self.currentHolders[serial] != nil:
                    "This serial has not been created yet."
            }
            let data = self.currentHolders[serial]!
            let collection = getAccount(data.address).getCapability(FLOAT.FLOATCollectionPublicPath).borrow<&Collection{CollectionPublic}>() 
            if collection?.borrowFLOAT(id: data.id) != nil {
                return data
            }
                
            return nil
        }

        // Returns an accurate dictionary of all the
        // claimers
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

        // Gets all the verifiers that will be used
        // for claiming
        pub fun getVerifiers(): {String: [{IVerifier}]} {
            return self.verifiers
        }

        pub fun getGroups(): [String] {
            return self.groups.keys
        }

        pub fun getViews(): [Type] {
             return [
                Type<MetadataViews.Display>()
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
            }

            return nil
        }

        /****************** Getting a FLOAT ******************/

        // Will not panic if one of the recipients has already claimed.
        // It will just skip them.
        pub fun batchMint(recipients: [&Collection{NonFungibleToken.CollectionPublic}]) {
            for recipient in recipients {
                if self.claimed[recipient.owner!.address] == nil {
                    self.mint(recipient: recipient)
                }
            }
        }

        // Used to give a person a FLOAT from this event.
        // Used as a helper function for `claim`, but can also be 
        // used by the event owner and shared accounts to
        // mint directly to a user. 
        //
        // If the event owner directly mints to a user, it does not
        // run the verifiers on the user. It bypasses all of them.
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
            // Saves the claimer
            self.claimed[recipientAddr] = TokenIdentifier(
                _id: id,
                _address: recipientAddr,
                _serial: serial
            )
            // Saves the claimer as the current holder
            // of the newly minted FLOAT
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
            
            params["event"] = &self as &FLOATEvent{FLOATEventPublic}
            params["claimee"] = recipient.owner!.address
            
            // Runs a loop over all the verifiers that this FLOAT Events
            // implements. For example, "Limited", "Timelock", "Secret", etc.  
            // All the verifiers are in the FLOATVerifiers.cdc contract
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
            _extraMetadata: {String: AnyStruct},
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

        destroy() {
            emit FLOATEventDestroyed(eventId: self.eventId, host: self.host, name: self.name)
        }
    }

    // A container of FLOAT Events (maybe because they're similar to
    // one another, or an event host wants to list all their AMAs together, etc).
    pub resource Group {
        pub let id: UInt64
        pub let name: String
        pub let image: String
        pub let description: String
        // All the FLOAT Events that belong
        // to this group.
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
            self.id = self.uuid
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
        pub fun borrowPublicEventRef(eventId: UInt64): &FLOATEvent{FLOATEventPublic}?
        pub fun getAllEvents(): {UInt64: String}
        pub fun getIDs(): [UInt64]
        pub fun getGroup(groupName: String): &Group?
        pub fun getGroups(): [String]
        // Account Getters
        access(account) fun borrowEventsRef(): &FLOATEvents
    }

    // A "Collection" of FLOAT Events
    pub resource FLOATEvents: FLOATEventsPublic, MetadataViews.ResolverCollection {
        // All the FLOAT Events this collection stores
        access(account) var events: @{UInt64: FLOATEvent}
        // All the Groups this collection stores
        access(account) var groups: @{String: Group}

        // Creates a new FLOAT Event by passing in some basic parameters
        // and a list of all the verifiers this event must abide by
        pub fun createEvent(
            claimable: Bool,
            description: String,
            image: String, 
            name: String, 
            transferrable: Bool,
            url: String,
            verifiers: [{IVerifier}],
            _ extraMetadata: {String: AnyStruct},
            initialGroups: [String]
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
            self.events[eventId] <-! FLOATEvent

            for groupName in initialGroups {
                self.addEventToGroup(groupName: groupName, eventId: eventId)
            }
            return eventId
        }

        // Deletes an event. Also makes sure to remove
        // the event from all the groups its in.
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
            self.groups[groupName] <-! create Group(_name: groupName, _image: image, _description: description)
        }

        // Deletes a group. Also makes sure to remove
        // the group from all the events that use it.
        pub fun deleteGroup(groupName: String) {
            let eventsInGroup = self.groups[groupName]?.getEvents() 
                                ?? panic("This Group does not exist.")
            for eventId in eventsInGroup {
                let ref = &self.events[eventId] as &FLOATEvent
                ref.removeFromGroup(groupName: groupName)
            }
            destroy self.groups.remove(key: groupName)
        }

        // Adds an event to a group. Also adds the group
        // to the event.
        pub fun addEventToGroup(groupName: String, eventId: UInt64) {
            pre {
                self.groups[groupName] != nil: "This group does not exist."
                self.events[eventId] != nil: "This event does not exist."
            }
            let groupRef = &self.groups[groupName] as &Group
            groupRef.addEvent(eventId: eventId)

            let eventRef = self.borrowEventRef(eventId: eventId)!
            eventRef.addToGroup(groupName: groupName)
        }

        // Simply takes the event away from the group
        pub fun removeEventFromGroup(groupName: String, eventId: UInt64) {
            pre {
                self.groups[groupName] != nil: "This group does not exist."
                self.events[eventId] != nil: "This event does not exist."
            }
            let groupRef = &self.groups[groupName] as &Group
            groupRef.removeEvent(eventId: eventId)

            let eventRef = self.borrowEventRef(eventId: eventId)!
            eventRef.removeFromGroup(groupName: groupName)
        }

        pub fun getGroup(groupName: String): &Group? {
            if self.groups[groupName] != nil {
                return &self.groups[groupName] as &Group
            }
            return nil
        }
        
        pub fun getGroups(): [String] {
            return self.groups.keys
        }

        // Only accessible to people who share your account. 
        // If `fromHost` has allowed you to share your account
        // in the GrantedAccountAccess.cdc contract, you can get a reference
        // to their FLOATEvents here and do pretty much whatever you want.
        pub fun borrowSharedRef(fromHost: Address): &FLOATEvents {
            let sharedInfo = getAccount(fromHost).getCapability(GrantedAccountAccess.InfoPublicPath)
                                .borrow<&GrantedAccountAccess.Info{GrantedAccountAccess.InfoPublic}>() 
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

        pub fun borrowEventRef(eventId: UInt64): &FLOATEvent? {
            if self.events[eventId] != nil {
                return &self.events[eventId] as &FLOATEvent
            }
            return nil
        }

        /************* Getters (for anyone) *************/

        // Get a public reference to the FLOATEvent
        // so you can call some helpful getters
        pub fun borrowPublicEventRef(eventId: UInt64): &FLOATEvent{FLOATEventPublic}? {
            if self.events[eventId] != nil {
                return &self.events[eventId] as &FLOATEvent{FLOATEventPublic}
            }
            return nil
        }

        pub fun getIDs(): [UInt64] {
            return self.events.keys
        }

        // Maps the eventId to the name of that
        // event. Just a kind helper.
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
            self.groups <- {}
        }

        destroy() {
            destroy self.events
            destroy self.groups
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

        self.FLOATCollectionStoragePath = /storage/FLOATCollectionStoragePath
        self.FLOATCollectionPublicPath = /public/FLOATCollectionPublicPath
        self.FLOATEventsStoragePath = /storage/FLOATEventsStoragePath
        self.FLOATEventsPrivatePath = /private/FLOATEventsPrivatePath
        self.FLOATEventsPublicPath = /public/FLOATEventsPublicPath
    }
}