import FLOATMetadataViews from "./FLOATMetadataViews.cdc"
import NonFungibleToken from "./core-contracts/NonFungibleToken.cdc"
import MetadataViews from "./core-contracts/MetadataViews.cdc"

pub contract FLOAT: NonFungibleToken {

    //
    // Paths
    //
    pub let FLOATCollectionStoragePath: StoragePath
    pub let FLOATCollectionPublicPath: PublicPath
    pub let FLOATEventsStoragePath: StoragePath
    pub let FLOATEventsPublicPath: PublicPath
    pub let FLOATEventsPrivatePath: PrivatePath

    //
    // Events
    //
    pub event ContractInitialized()
    pub event FLOATMinted(id: UInt64, eventHost: Address, eventId: UInt64, serial: UInt64, recipient: Address)
    pub event FLOATDeposited(to: Address, id: UInt64)
    pub event FLOATDestroyed(id: UInt64, eventHost: Address, eventId: UInt64, serial: UInt64)
    pub event FLOATWithdrawn(from: Address, id: UInt64)
    pub event FLOATEventCreated(host: Address, id: UInt64, name: String)
    pub event FLOATEventDestroyed(host: Address, id: UInt64, name: String)

    // Throw away for standard
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id: UInt64, to: Address?)

    //
    // State
    //
    pub var totalSupply: UInt64
    pub var totalFLOATEvents: UInt64

    //
    // NFT
    //
    pub resource NFT: NonFungibleToken.INFT, MetadataViews.Resolver {
        pub let id: UInt64

        pub let dateReceived: UFix64
        pub let eventHost: Address
        pub let eventId: UInt64
        pub let originalRecipient: Address
        pub let serial: UInt64

        // Helper function to get the metadata of the event this FLOAT
        // is from
        pub fun getFLOATEvent(): FLOATMetadataViews.FLOATEventMetadataView? {
            let floatEventCollection = getAccount(self.eventHost).getCapability(FLOAT.FLOATEventsPublicPath)
                                        .borrow<&FLOAT.FLOATEvents{MetadataViews.ResolverCollection}>()
                                        ?? panic("Could not borrow the FLOAT Events Collection from the eventHost.")
            let floatEvent = floatEventCollection.borrowViewResolver(id: self.eventId)

            if let metadata = floatEvent.resolveView(Type<FLOATMetadataViews.FLOATEventMetadataView>()) {
                return metadata as! FLOATMetadataViews.FLOATEventMetadataView
            }
            return nil
        }

        pub fun getViews(): [Type] {
             return [
                Type<FLOATMetadataViews.FLOATMetadataView>(),
                Type<FLOATMetadataViews.Identifier>(),
                Type<MetadataViews.Display>()
            ]
        }

        pub fun resolveView(_ view: Type): AnyStruct? {
            switch view {
                case Type<FLOATMetadataViews.FLOATMetadataView>():
                    return FLOATMetadataViews.FLOATMetadataView(
                        _id: self.id,
                        _dateReceived: self.dateReceived,
                        _eventId: self.eventId,
                        _eventHost: self.eventHost,
                        _originalRecipient: self.originalRecipient,
                        _serial: self.serial,
                        _eventMetadata: self.getFLOATEvent()
                    )
                case Type<FLOATMetadataViews.Identifier>():
                    return FLOATMetadataViews.Identifier(id: self.id, serial: self.serial, address: self.owner!.address) 
                case Type<MetadataViews.Display>():
                    let FLOATEventMetadata = self.getFLOATEvent() ?? panic("FLOAT Event must have been deleted.")
                    return MetadataViews.Display(
                        name: FLOATEventMetadata.name, 
                        description: FLOATEventMetadata.description, 
                        file: MetadataViews.IPFSFile(cid: FLOATEventMetadata.image, path: nil)
                    )
            }

            return nil
        }

        init(_eventHost: Address, _eventId: UInt64, _serial: UInt64, _recipient: Address) {
            self.id = self.uuid
            self.dateReceived = getCurrentBlock().timestamp
            self.eventHost = _eventHost
            self.eventId = _eventId
            self.originalRecipient = _recipient
            self.serial = _serial
            
            emit FLOATMinted(
                id: self.id, 
                eventHost: self.eventHost, 
                eventId: self.eventId, 
                serial: self.serial, 
                recipient: self.originalRecipient
            )

            FLOAT.totalSupply = FLOAT.totalSupply + 1
        }

        destroy() {
            let floatEvents: &FLOATEvents{FLOATEventsPublic} = 
                getAccount(self.eventHost).getCapability(FLOAT.FLOATEventsPublicPath)
                    .borrow<&FLOATEvents{FLOATEventsPublic}>()
                    ?? panic("Could not get the FLOAT Events from the eventHost.")
            let floatEvent: &FLOATEvent = floatEvents.getEvent(id: self.eventId)
            floatEvent.accountDeletedFLOAT(account: self.originalRecipient)
            emit FLOATDestroyed(
                id: self.id, 
                eventHost: self.eventHost, 
                eventId: self.eventId, 
                serial: self.serial
            )
        }
    }

    //
    // Collection
    //
    pub resource Collection: NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection {
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

        pub fun deposit(token: @NonFungibleToken.NFT) {
            let nft <- token as! @NFT
            emit FLOATDeposited(to: self.owner!.address, id: nft.id)
            self.ownedNFTs[nft.id] <-! nft
        }

        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("You do not own this FLOAT in your collection")
            let nft <- token as! @NFT
            
            let floatEvent = nft.getFLOATEvent() ?? panic("This FLOAT Event must have been deleted.")
            assert(floatEvent.transferrable, message: "This FLOAT is not transferrable.")
            emit FLOATWithdrawn(from: self.owner!.address, id: nft.id)
            return <- nft
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

    //
    // FLOATEvent
    //
    pub resource FLOATEvent: MetadataViews.Resolver {
        pub var active: Bool
        access(account) var claimed: {Address: FLOATMetadataViews.Identifier}
        pub let dateCreated: UFix64
        pub let description: String 
        pub let host: Address
        pub let id: UInt64
        pub let image: String 
        pub let name: String
        access(account) let metadata: {String: String}
        pub var totalSupply: UInt64
        pub var transferrable: Bool
        pub let url: String
        
        // Event options
        pub let claimable: Bool
        pub let Timelock: Timelock?
        pub let Secret: Secret?
        pub let Limited: Limited?

        pub fun isOpen(): Bool {
            var open: Bool = true

            if let Timelock = self.Timelock {
                if getCurrentBlock().timestamp < Timelock.dateStart || 
                   getCurrentBlock().timestamp > Timelock.dateEnding {
                    open = false
                }
            }

            if let Limited = self.Limited {
                if self.totalSupply >= Limited.capacity {
                    open = false
                }
            }

            return self.active && open
        }

        pub fun toggleActive(): Bool {
            self.active = !self.active
            return self.active
        }

        pub fun toggleTransferrable(): Bool {
            self.transferrable = !self.transferrable
            return self.transferrable
        }

        access(account) fun accountDeletedFLOAT(account: Address) {
            self.claimed.remove(key: account)
            self.totalSupply = self.totalSupply - 1
        }

        // Helper function to mint FLOATs.
        access(account) fun mint(recipient: &Collection{NonFungibleToken.CollectionPublic}) {
            pre {
                self.claimed[recipient.owner!.address] == nil:
                    "This person already claimed their FLOAT!"
            }
            let serial: UInt64 = self.totalSupply
            let recipientAddr: Address = recipient.owner!.address

            let token <- create NFT(
                _eventHost: self.host, 
                _eventId: self.id, 
                _serial: serial, 
                _recipient: recipientAddr
            ) 
            self.claimed[recipientAddr] = FLOATMetadataViews.Identifier(
                _id: token.id,
                _serial: token.serial,
                _address: recipientAddr
            )
            self.totalSupply = serial + 1
            recipient.deposit(token: <- token)
        }

        pub fun getViews(): [Type] {
             return [
                Type<FLOATMetadataViews.FLOATEventMetadataView>()
            ]
        }

        pub fun resolveView(_ view: Type): AnyStruct? {
            switch view {
                case Type<FLOATMetadataViews.FLOATEventMetadataView>():
                    return FLOATMetadataViews.FLOATEventMetadataView(
                        _claimable: self.claimable,
                        _id: self.id,
                        _host: self.host, 
                        _name: self.name,
                        _description: self.description, 
                        _image: self.image, 
                        _url: self.url,
                        _transferrable: self.transferrable,
                        _metadata: self.metadata,
                        _dateCreated: self.dateCreated,
                        _totalSupply: self.totalSupply,
                        _claimed: self.claimed,
                        _startTime: self.Timelock?.dateStart,
                        _endTime: self.Timelock?.dateEnding,
                        _requiresSecret: self.Secret?.secretPhrase != nil,
                        _capacity: self.Limited?.capacity,
                        _isOpen: self.isOpen(),
                        _active: self.active
                    )
            }

            return nil
        }

        init (
            _claimable: Bool, 
            _timelock: Timelock?,
            _secret: Secret?,
            _limited: Limited?,
            _host: Address, 
            _name: String,
            _description: String, 
            _image: String, 
            _url: String,
            _transferrable: Bool,
            _metadata: {String: String}
        ) {
            self.id = self.uuid
            self.host = _host
            self.name = _name
            self.description = _description
            self.image = _image
            self.url = _url
            self.transferrable = _transferrable
            self.metadata = _metadata

            self.dateCreated = getCurrentBlock().timestamp
            self.totalSupply = 0
            self.claimed = {}
            self.active = true

            self.claimable = _claimable
            self.Timelock = _timelock
            self.Secret = _secret
            self.Limited = _limited

            FLOAT.totalFLOATEvents = FLOAT.totalFLOATEvents + 1
            emit FLOATEventCreated(host: self.host, id: self.id, name: self.name)
        }

        destroy() {
            if self.totalSupply != 0 {
                panic("You cannot delete this event because the total supply is not 0.")
            }
            emit FLOATEventDestroyed(host: self.host, id: self.id, name: self.name)
        }
    }

    // 
    // Timelock
    //
    pub struct Timelock {
        // An automatic switch handled by the contract
        // to stop people from claiming after a certain time.
        pub let dateStart: UFix64
        pub let dateEnding: UFix64

        access(account) fun verify() {
            assert(
                getCurrentBlock().timestamp >= self.dateStart,
                message: "This FLOAT Event has not started yet."
            )
            assert(
                getCurrentBlock().timestamp <= self.dateEnding,
                message: "Sorry! The time has run out to mint this FLOAT."
            )
        }

        init(_dateStart: UFix64, _timePeriod: UFix64) {
            self.dateStart = _dateStart
            self.dateEnding = self.dateStart + _timePeriod
        }
    }

    //
    // Secret
    //
    pub struct Secret {
        // The secret code, set by the owner of this event.
        access(account) var secretPhrase: String

        access(account) fun verify(secretPhrase: String?) {
            assert(
                secretPhrase != nil,
                message: "You must input a secret phrase."
            )
            assert(
                self.secretPhrase == secretPhrase, 
                message: "You did not input the correct secret phrase."
            )
        }

        init(_secretPhrase: String) {
            self.secretPhrase = _secretPhrase
        }
    }

    //
    // Limited
    //
    // If the maximum capacity is reached, this is no longer active.
    pub struct Limited {
        pub var capacity: UInt64

        access(account) fun verify(accountAddr: Address, currentCapacity: UInt64) {
            assert(
                currentCapacity < self.capacity,
                message: "This FLOAT Event is at capacity."
            )
        }

        init(_capacity: UInt64) {
            self.capacity = _capacity
        }
    }
 
    // 
    // FLOATEvents
    //
    pub resource interface FLOATEventsPublic {
        pub fun getAllEvents(): {String: UInt64}
        pub fun getOtherHosts(): [Address]
        pub fun addCreationCapability(minter: Capability<&FLOATEvents>) 
        pub fun claim(id: UInt64, recipient: &Collection, secret: String?)
        access(account) fun getEvent(id: UInt64): &FLOATEvent
    }

    pub resource FLOATEvents: FLOATEventsPublic, MetadataViews.ResolverCollection {
        // Makes sure a name is only being used once for every account.
        access(account) var nameToId: {String: UInt64}
        access(account) var events: @{UInt64: FLOATEvent}
        access(account) var otherHosts: {Address: Capability<&FLOATEvents>}

        // Create a new FLOAT Event.
        pub fun createEvent(
            claimable: Bool, 
            timelock: Timelock?, 
            secret: Secret?, 
            limited: Limited?, 
            name: String, 
            description: String, 
            image: String, 
            url: String,
            transferrable: Bool,
            _ metadata: {String: String}
        ) {
            pre {
                self.nameToId[name] == nil: 
                    "An event with this name already exists in your Collection."
            }

            let FLOATEvent <- create FLOATEvent(
                _claimable: claimable, 
                _timelock: timelock,
                _secret: secret,
                _limited: limited,
                _host: self.owner!.address, 
                _name: name, 
                _description: description, 
                _image: image, 
                _url: url,
                _transferrable: transferrable,
                _metadata: metadata
            )
            self.nameToId[FLOATEvent.name] = FLOATEvent.id
            self.events[FLOATEvent.id] <-! FLOATEvent
        }

        // Delete an event if you made a mistake.
        pub fun deleteEvent(id: UInt64) {
            let name: String = self.getEvent(id: id).name

            self.nameToId.remove(key: name)
            let event <- self.events.remove(key: id) ?? panic("This event does not exist")
            destroy event
        }

        // A method for receiving a &FLOATEvent Capability. This is if 
        // a different account wants you to be able to handle their FLOAT Events
        // for them, so imagine if you're on a team of people and you all handle
        // one account.
        pub fun addCreationCapability(minter: Capability<&FLOATEvents>) {
            self.otherHosts[minter.borrow()!.owner!.address] = minter
        }

        // Get the Capability to do stuff with this FLOATEvents resource.
        pub fun getCreationCapability(host: Address): &FLOATEvents? {
            let cap: Capability<&FLOATEvents> = self.otherHosts[host] 
                        ?? panic("You don't have access to this account's FLOATEvents.")

            if cap.borrow() == nil {
                self.otherHosts.remove(key: host)
            }

            return cap.borrow()
        }

        pub fun getOtherHosts(): [Address] {
            return self.otherHosts.keys
        }

        // Get a view of the FLOATEvent.
        pub fun getEvent(id: UInt64): &FLOATEvent {
            return &self.events[id] as &FLOATEvent
        }

        pub fun borrowViewResolver(id: UInt64): &{MetadataViews.Resolver} {
            let floatRef = self.getEvent(id: id)
            return floatRef as &{MetadataViews.Resolver}
        }

        pub fun getIDs(): [UInt64] {
            return self.events.keys
        }

        // Return all the FLOATEvents.
        pub fun getAllEvents(): {String: UInt64} {
            return self.nameToId
        }

        /*************************************** CLAIMING ***************************************/

        // This is for distributing NotClaimable FLOAT Events.
        // NOT available to the public.
        pub fun distributeDirectly(id: UInt64, recipient: &Collection{NonFungibleToken.CollectionPublic} ) {
            pre {
                self.events[id] != nil:
                    "This event does not exist."
                !self.getEvent(id: id).claimable:
                    "This event is Claimable."
            }
            let FLOATEvent = self.getEvent(id: id)
            FLOATEvent.mint(recipient: recipient)
        }

        // This is for claiming Claimable FLOAT Events.
        //
        // The `secret` parameter is only necessary if you're claiming a `Secret` FLOAT.
        // Available to the public.
        pub fun claim(id: UInt64, recipient: &Collection, secret: String?) {
            pre {
                self.getEvent(id: id).active: 
                    "This FLOATEvent is not active."
                self.getEvent(id: id).claimable:
                    "This event is NotClaimable."
            }
            let FLOATEvent: &FLOATEvent = self.getEvent(id: id)
            
            // If the FLOATEvent has the `Timelock` Prop
            if FLOATEvent.Timelock != nil {
                let Timelock: &Timelock = &FLOATEvent.Timelock! as &Timelock
                Timelock.verify()
            } 

            // If the FLOATEvent has the `Secret` Prop
            if FLOATEvent.Secret != nil {
                let Secret: &Secret = &FLOATEvent.Secret! as &Secret
                Secret.verify(secretPhrase: secret)
            }

            // If the FLOATEvent has the `Limited` Prop
            if FLOATEvent.Limited != nil {
                let Limited: &Limited = &FLOATEvent.Limited! as &Limited
                Limited.verify(accountAddr: recipient.owner!.address, currentCapacity: FLOATEvent.totalSupply)
            }

            // You have passed all the props (which act as restrictions).
            FLOATEvent.mint(recipient: recipient)
        }

        /******************************************************************************/

        init() {
            self.nameToId = {}
            self.events <- {}
            self.otherHosts = {}
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

        self.FLOATCollectionStoragePath = /storage/FLOATCollectionStoragePath006
        self.FLOATCollectionPublicPath = /public/FLOATCollectionPublicPath006
        self.FLOATEventsStoragePath = /storage/FLOATEventsStoragePath006
        self.FLOATEventsPublicPath = /public/FLOATEventsPublicPath006
        self.FLOATEventsPrivatePath = /private/FLOATEventsPrivatePath006
    }
}