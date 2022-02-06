import MetadataViews from "./MetadataViews.cdc"
import NonFungibleToken from "./NonFungibleToken.cdc"

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
    pub event FLOATMinted(id: UInt64, metadata: MetadataViews.FLOATMetadataView)
    pub event FLOATDeposited(to: Address, id: UInt64, metadata: MetadataViews.FLOATMetadataView)
    pub event FLOATWithdrawn(from: Address, id: UInt64, metadata: MetadataViews.FLOATMetadataView)
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
        pub let metadata: MetadataViews.FLOATMetadataView

        pub fun getViews(): [Type] {
             return [
                Type<MetadataViews.FLOATMetadataView>(),
                Type<MetadataViews.Identifier>(),
                Type<MetadataViews.Display>()
            ]
        }

        pub fun resolveView(_ view: Type): AnyStruct? {
            switch view {
                case Type<MetadataViews.FLOATMetadataView>():
                    return self.metadata
                case Type<MetadataViews.Identifier>():
                    return MetadataViews.Identifier(id: self.id, address: self.owner!.address) 
                case Type<MetadataViews.Display>():
                    return MetadataViews.Display(
                                                 name: self.metadata.name, 
                                                 description: self.metadata.description, 
                                                 file: MetadataViews.IPFSFile(cid: self.metadata.image, path: nil)
                                                )
            }

            return nil
        }

        init(_metadata: MetadataViews.FLOATMetadataView) {
            self.id = self.uuid
            self.metadata = _metadata

            let dateReceived = getCurrentBlock().timestamp
            emit FLOATMinted(id: self.id, metadata: self.metadata)

            FLOAT.totalSupply = FLOAT.totalSupply + 1
        }
    }

    //
    // Collection
    //
    pub resource Collection: NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection {
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

        pub fun deposit(token: @NonFungibleToken.NFT) {
            let nft <- token as! @NFT
            emit FLOATDeposited(to: self.owner!.address, id: nft.uuid, metadata: nft.metadata)
            self.ownedNFTs[nft.uuid] <-! nft
        }

        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("You do not own this FLOAT in your collection")
            let nft <- token as! @NFT
            
            assert(nft.metadata.transferrable, message: "This FLOAT is not transferrable.")
            emit FLOATWithdrawn(from: self.owner!.address, id: nft.uuid, metadata: nft.metadata)
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
        access(account) var claimed: {Address: UInt64}
        pub let dateCreated: UFix64
        pub let description: String 
        pub let host: Address
        pub let id: UInt64
        pub let image: String 
        pub let name: String
        access(account) let metadata: {String: String}
        pub var totalSupply: UInt64
        pub let transferrable: Bool
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
                if Limited.currentCapacity >= Limited.capacity {
                    open = false
                }
            }

            return self.active && open
        }

        access(account) fun toggleActive(): Bool {
            self.active = !self.active
            return self.active
        }

        // Helper function to mint FLOATs.
        access(account) fun mint(recipient: &Collection{NonFungibleToken.CollectionPublic}) {
            pre {
                self.claimed[recipient.owner!.address] == nil:
                    "This person already claimed their FLOAT!"
            }
            let serial: UInt64 = self.totalSupply
            let recipientAddr: Address = recipient.owner!.address

            let metadata = MetadataViews.FLOATMetadataView(
                                            _recipient: recipientAddr, 
                                            _serial: serial,
                                            _host: self.host, 
                                            _name: self.name, 
                                            _eventID: self.id,
                                            _description: self.description, 
                                            _image: self.image,
                                            _transferrable: self.transferrable
                                        )
            let token <- create NFT(_metadata: metadata) 
            recipient.deposit(token: <- token)

            self.claimed[recipientAddr] = serial
            self.totalSupply = serial + 1
        }

        pub fun getViews(): [Type] {
             return [
                Type<MetadataViews.FLOATEventMetadataView>()
            ]
        }

        pub fun resolveView(_ view: Type): AnyStruct? {
            switch view {
                case Type<MetadataViews.FLOATEventMetadataView>():
                    return MetadataViews.FLOATEventMetadataView(
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
                        _startTime: self.Timelock?.dateStart,
                        _endTime: self.Timelock?.dateEnding,
                        _requiresSecret: self.Secret?.secretPhrase != nil,
                        _capacity: self.Limited?.capacity,
                        _currentCapacity: self.Limited?.currentCapacity,
                        _isOpen: self.isOpen()
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
        // A list of accounts to get track on who is here first
        // Maps the position of who come first to their address.
        access(account) var accounts: {UInt64: Address}
        pub var currentCapacity: UInt64
        pub var capacity: UInt64

        access(account) fun verify(accountAddr: Address) {
            assert(
                self.currentCapacity < self.capacity,
                message: "This FLOAT Event is at capacity."
            )
            
            self.accounts[self.currentCapacity] = accountAddr
            self.currentCapacity = self.currentCapacity + 1
        }

        init(_capacity: UInt64) {
            self.accounts = {}
            self.currentCapacity = 0
            self.capacity = _capacity
        }
    }
 
    // 
    // FLOATEvents
    //
    pub resource interface FLOATEventsPublic {
        pub fun getAllEvents(): {String: UInt64}
        pub fun addCreationCapability(minter: Capability<&FLOATEvents>) 
        pub fun claim(id: UInt64, recipient: &Collection, secret: String?)
    }

    pub resource FLOATEvents: FLOATEventsPublic, MetadataViews.ResolverCollection {
        // Makes sure a name is only being used once for every account.
        access(account) var nameToID: {String: UInt64}
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
                self.nameToID[name] == nil: 
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
            self.nameToID[name] = FLOATEvent.id
            self.events[FLOATEvent.id] <-! FLOATEvent
        }

        pub fun toggleActive(id: UInt64): Bool {
            let event: &FLOATEvent = self.getEvent(id: id)
            return event.toggleActive()
        }

        // Delete an event if you made a mistake.
        pub fun deleteEvent(id: UInt64) {
            let name: String = self.getEvent(id: id).name

            self.nameToID[name] == nil
            let event <- self.events.remove(key: id)
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
        pub fun getCreationCapability(host: Address): Capability<&FLOATEvents> {
            return self.otherHosts[host]!
        }

        // Get a view of the FLOATEvent.
        access(account) fun getEvent(id: UInt64): &FLOATEvent {
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
            return self.nameToID
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
                Limited.verify(accountAddr: recipient.owner!.address)
            }

            // You have passed all the props (which act as restrictions).
            FLOATEvent.mint(recipient: recipient)
        }

        /******************************************************************************/

        init() {
            self.nameToID = {}
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

        self.FLOATCollectionStoragePath = /storage/FLOATCollectionStoragePath
        self.FLOATCollectionPublicPath = /public/FLOATCollectionPublicPath
        self.FLOATEventsStoragePath = /storage/FLOATEventsStoragePath
        self.FLOATEventsPublicPath = /public/FLOATEventsPublicPath
        self.FLOATEventsPrivatePath = /private/FLOATEventsPrivatePath
    }
}