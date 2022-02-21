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
    pub event FLOATMinted(id: UInt64, eventHost: Address, eventId: UInt64, recipient: Address, serial: UInt64)
    pub event FLOATClaimed(eventHost: Address, eventId: UInt64, eventImage: String, eventName: String, recipient: Address, serial: UInt64)
    pub event FLOATDeposited(id: UInt64, to: Address)
    pub event FLOATDestroyed(id: UInt64, eventHost: Address, eventId: UInt64, serial: UInt64)
    pub event FLOATTransferred(id: UInt64, from: Address, to: Address, eventHost: Address, eventId: UInt64, serial: UInt64)
    pub event FLOATEventCreated(id: UInt64, host: Address, name: String)
    pub event FLOATEventDestroyed(id: UInt64, host: Address, name: String)

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

        // A capability that points to metadata about the FLOAT event
        // this FLOAT is from.
        pub let eventCap: Capability<&FLOATEvents{FLOATEventsPublic, MetadataViews.ResolverCollection}>
        
        // Helper function to get the metadata of the event 
        // this FLOAT is from
        pub fun getEventMetadata(): FLOATMetadataViews.FLOATEventMetadataView? {
            if let floatEventCollection = self.eventCap.borrow() {
                let floatEvent = floatEventCollection.borrowViewResolver(id: self.eventId)

                if let metadata = floatEvent.resolveView(Type<FLOATMetadataViews.FLOATEventMetadataView>()) {
                    return metadata as! FLOATMetadataViews.FLOATEventMetadataView
                }
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
                        _owner: self.owner!.address,
                        _serial: self.serial,
                        _eventMetadata: self.getEventMetadata()
                    )
                case Type<FLOATMetadataViews.Identifier>():
                    return FLOATMetadataViews.Identifier(id: self.id, serial: self.serial, address: self.owner!.address) 
                case Type<MetadataViews.Display>():
                    let eventMetadata = self.getEventMetadata() ?? panic("FLOAT Event must have been deleted.")
                    return MetadataViews.Display(
                        name: eventMetadata.name, 
                        description: eventMetadata.description, 
                        file: MetadataViews.IPFSFile(cid: eventMetadata.image, path: nil)
                    )
            }

            return nil
        }

        init(_eventHost: Address, _eventId: UInt64, _recipient: Address, _serial: UInt64) {
            self.id = self.uuid
            self.dateReceived = getCurrentBlock().timestamp
            self.eventHost = _eventHost
            self.eventId = _eventId
            self.originalRecipient = _recipient
            self.serial = _serial

            self.eventCap = getAccount(_eventHost)
                            .getCapability<&FLOATEvents{FLOATEventsPublic, MetadataViews.ResolverCollection}>(FLOAT.FLOATEventsPublicPath)
            
            emit FLOATMinted(
                id: self.id, 
                eventHost: self.eventHost, 
                eventId: self.eventId, 
                recipient: self.originalRecipient,
                serial: self.serial
            )

            FLOAT.totalSupply = FLOAT.totalSupply + 1
        }

        // When destroyed, we make sure to update the FLOAT Event metadata
        // (specifically to remove this user as a current holder of this FLOAT)
        destroy() {
            let floatEvents: &FLOATEvents{FLOATEventsPublic} = self.eventCap.borrow() 
                ?? panic("This Event Collection this FLOAT came from has been deleted.")
            let floatEvent: &FLOATEvent = floatEvents.getEventRef(id: self.eventId)
            floatEvent.accountDeletedFLOAT(serial: self.serial)
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
            emit FLOATDeposited(id: nft.id, to: self.owner!.address, )
            self.ownedNFTs[nft.id] <-! nft
        }

        // Function is disabled, but here to fit the NonFungibleToken standard
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
            
            let floatEvents: &FLOATEvents{FLOATEventsPublic} = nft.eventCap.borrow() ?? panic("This Event Collection this FLOAT came from has been deleted.")
            let floatEvent: &FLOATEvent = floatEvents.getEventRef(id: nft.eventId)
            floatEvent.transferred(id: nft.id, serial: nft.serial, to: recipient.owner!.address)
            assert(floatEvent.transferrable, message: "This FLOAT is not transferrable.")
            emit FLOATTransferred(id: nft.id, from: self.owner!.address, to: recipient.owner!.address, eventHost: nft.eventHost, eventId: nft.eventId, serial: nft.serial)
            recipient.deposit(token: <- nft)
        }

        // Only returns NFT IDs for which
        // you can still receive event metadata
        // from (meaning the event host didn't
        // unlink their FLOATEvents resource to
        // the public)
        pub fun getIDs(): [UInt64] {
            let ids = self.ownedNFTs.keys
            let answer: [UInt64] = []
            for id in ids {
                let tokenRef = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
                let nftRef = tokenRef as! &NFT
                if nftRef.eventCap.check() {
                    answer.append(id)
                }
            }
            return answer
        }

        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return &self.ownedNFTs[id] as &NonFungibleToken.NFT
        }

        pub fun borrowViewResolver(id: UInt64): &{MetadataViews.Resolver} {
            let tokenRef = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
            let nftRef = tokenRef as! &NFT
            return nftRef as &{MetadataViews.Resolver}
        }

        // Since you can't withdraw FLOATs, this allows you to delete a FLOAT
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

    pub resource interface FLOATEventPublic {
        pub fun hasClaimed(account: Address): FLOATMetadataViews.Identifier?
        pub fun getCurrentHolder(serial: UInt64): FLOATMetadataViews.Identifier?
        pub fun isOpen(): Bool
    }

    //
    // FLOATEvent
    //
    pub resource FLOATEvent: FLOATEventPublic, MetadataViews.Resolver {
        // A manual toggle the event host can turn
        // on and off to stop claiming
        pub var claimable: Bool
        // Maps the serial of the float to:
        /*
        { 
            id: uuid of the float
            serial: serial of the float
            address: original recipient (or "claimer")
        }
        */
        access(account) var claimed: {Address: FLOATMetadataViews.Identifier}
        // Maps the serial of the float to:
        /*
        { 
            id: uuid of the float
            serial: serial of the float
            address: current holder
        } 
        */ 
        access(account) var currentHolders: {UInt64: FLOATMetadataViews.Identifier}
        pub let dateCreated: UFix64
        pub let description: String 
        pub let host: Address
        pub let id: UInt64
        pub let image: String 
        pub let name: String
        access(account) var extraMetadata: {String: String}
        pub var totalSupply: UInt64
        pub var transferrable: Bool
        pub let url: String
        
        // Event options
        pub let Timelock: Timelock?
        pub let Secret: Secret?
        pub let Limited: Limited?

        pub fun hasClaimed(account: Address): FLOATMetadataViews.Identifier? {
            return self.claimed[account]
        }

        pub fun getCurrentHolder(serial: UInt64): FLOATMetadataViews.Identifier? {
            return self.currentHolders[serial]
        }

        // It is "open" if:
        // 1. the event host didn't manually turn it off
        // 2. it is within a time period (only if Timelock is selected)
        // 3. it is not at capacity yet (only if Limited is selected)
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

            return self.claimable && open
        }

        // Manually pauses claiming
        pub fun toggleClaimable(): Bool {
            self.claimable = !self.claimable
            return self.claimable
        }

        // Stops users from transferring to one another
        pub fun toggleTransferrable(): Bool {
            self.transferrable = !self.transferrable
            return self.transferrable
        }

        pub fun updateMetadata(newExtraMetadata: {String: String}) {
            self.extraMetadata = newExtraMetadata
        }

        // Called if a user transfers their FLOAT to another user.
        // Needed so we can keep track of who currently has it
        access(account) fun transferred(id: UInt64, serial: UInt64, to: Address) {
            self.currentHolders[serial] = FLOATMetadataViews.Identifier(
                id: id,
                serial: serial,
                address: to
            )
        }

        // Called if a user deletes their FLOAT
        access(account) fun accountDeletedFLOAT(serial: UInt64) {
            self.currentHolders.remove(key: serial)
        }

        // Helper function to mint FLOATs.
        access(account) fun mint(recipient: &Collection{NonFungibleToken.CollectionPublic}) {
            pre {
                self.claimed[recipient.owner!.address] == nil:
                    "This person already claimed their FLOAT!"
            }
            let recipientAddr: Address = recipient.owner!.address
            let serial = self.totalSupply

            let token <- create NFT(
                _eventHost: self.host, 
                _eventId: self.id,
                _recipient: recipientAddr, 
                _serial: serial
            ) 
            self.claimed[recipientAddr] = FLOATMetadataViews.Identifier(
                _id: token.id,
                _serial: serial,
                _address: recipientAddr
            )
            self.currentHolders[serial] = FLOATMetadataViews.Identifier(
                _id: token.id,
                _serial: serial,
                _address: recipientAddr
            )

            self.totalSupply = self.totalSupply + 1
            recipient.deposit(token: <- token)
        }

        pub fun getViews(): [Type] {
             return [
                Type<FLOATMetadataViews.FLOATEventMetadataView>(),
                Type<FLOATMetadataViews.FLOATEventClaimed>(),
                Type<FLOATMetadataViews.FLOATEventHolders>()
            ]
        }

        pub fun resolveView(_ view: Type): AnyStruct? {
            switch view {
                case Type<FLOATMetadataViews.FLOATEventMetadataView>():
                    return FLOATMetadataViews.FLOATEventMetadataView(
                        _claimable: self.claimable,
                        _capacity: self.Limited?.capacity,
                        _dateCreated: self.dateCreated,
                        _description: self.description, 
                        _endTime: self.Timelock?.dateEnding,
                        _extraMetadata: self.extraMetadata,
                        _host: self.host, 
                        _id: self.id,
                        _image: self.image, 
                        _isOpen: self.isOpen(),
                        _name: self.name,
                        _requiresSecret: self.Secret?.secretPhrase != nil,
                        _startTime: self.Timelock?.dateStart,
                        _totalSupply: self.totalSupply,
                        _transferrable: self.transferrable,
                        _url: self.url
                    ) 
                case Type<FLOATMetadataViews.FLOATEventClaimed>():
                    return FLOATMetadataViews.FLOATEventClaimed(
                        _id: self.id,
                        _host: self.host,
                        _claimed: self.claimed
                    )
                case Type<FLOATMetadataViews.FLOATEventHolders>():
                    return FLOATMetadataViews.FLOATEventHolders(
                        _id: self.id,
                        _host: self.host,
                        _currentHolders: self.currentHolders
                    )
            }

            return nil
        }

        init (
            _claimable: Bool,
            _description: String, 
            _extraMetadata: {String: String},
            _host: Address, 
            _image: String, 
            _limited: Limited?,
            _name: String,
            _secret: Secret?,
            _timelock: Timelock?,
            _transferrable: Bool,
            _url: String
        ) {
            self.claimable = _claimable
            self.claimed = {}
            self.currentHolders = {}
            self.dateCreated = getCurrentBlock().timestamp
            self.description = _description
            self.host = _host
            self.id = self.uuid
            self.image = _image
            self.extraMetadata = _extraMetadata
            self.name = _name
            self.transferrable = _transferrable
            self.totalSupply = 0
            self.url = _url
            
            self.Timelock = _timelock
            self.Secret = _secret
            self.Limited = _limited

            FLOAT.totalFLOATEvents = FLOAT.totalFLOATEvents + 1
            emit FLOATEventCreated(id: self.id, host: self.host, name: self.name)
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
            emit FLOATEventDestroyed(id: self.id, host: self.host, name: self.name)
        }
    }

    // 
    // Timelock
    //
    // Specifies a time range in which the 
    // FLOAT from an event can be claimed
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
    // Specifies a secret code in order
    // to claim a FLOAT (not very secure, but cool feature)
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
    // Specifies a limit for the amount of people
    // who can CLAIM. Not to be confused with how many currently
    // hold a FLOAT from this event, since users can
    // delete their FLOATs.
    pub struct Limited {
        pub var capacity: UInt64

        access(account) fun verify(currentCapacity: UInt64) {
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
        // Setters
        pub fun claim(id: UInt64, recipient: &Collection, secret: String?)
        access(account) fun receiveSharing(fromHost: &FLOATEvents) 
        access(account) fun removeSharing(ofHost: &FLOATEvents)
        access(account) fun getEventRef(id: UInt64): &FLOATEvent
        // Getters
        pub fun getAllEvents(): {String: UInt64}
        pub fun getAddressWhoICanMintFor(): [Address]
        pub fun getAddressWhoCanMintForMe(): [Address]
        pub fun getPublicEventRef(id: UInt64): &FLOATEvent{FLOATEventPublic}
    }

    // Separating this into a separate interface
    // allows the FLOATEvent owner to completely
    // halt all shared minters from having control.
    pub resource interface FLOATEventsSharedMinter {
        access(account) fun getRef(): &FLOATEvents
    }

    pub resource FLOATEvents: FLOATEventsPublic, FLOATEventsSharedMinter, MetadataViews.ResolverCollection {
        // Makes sure a name is only being used once for every account.
        access(account) var nameToId: {String: UInt64}
        access(account) var events: @{UInt64: FLOATEvent}
        // A list of accounts you can mint for
        access(account) var canMintForThem: {Address: Bool}
        // A list of accounts you are allowing to mint for you
        access(account) var canMintForMe: {Address: Bool}

        // Create a new FLOAT Event.
        pub fun createEvent(
            claimable: Bool,
            description: String,
            image: String, 
            limited: Limited?, 
            name: String, 
            secret: Secret?, 
            timelock: Timelock?, 
            transferrable: Bool,
            url: String,
            _ extraMetadata: {String: String}
        ) {
            pre {
                self.nameToId[name] == nil: 
                    "An event with this name already exists in your Collection."
            }

            let FLOATEvent <- create FLOATEvent(
                _claimable: claimable,
                _description: description, 
                _extraMetadata: extraMetadata,
                _host: self.owner!.address, 
                _image: image, 
                _limited: limited,
                _name: name, 
                _secret: secret,
                _timelock: timelock,
                _transferrable: transferrable,
                _url: url
            )
            self.nameToId[FLOATEvent.name] = FLOATEvent.id
            self.events[FLOATEvent.id] <-! FLOATEvent
        }

        // Delete an event if you made a mistake.
        // You can only delete an event if 0 people
        // are currently holding that FLOAT, as written in the
        // destroy() function of the FLOATEvent resource.
        pub fun deleteEvent(id: UInt64) {
            let name: String = self.getEventRef(id: id).name

            self.nameToId.remove(key: name)
            let event <- self.events.remove(key: id) ?? panic("This event does not exist")
            destroy event
        }

        // Get a view of the FLOATEvent.
        pub fun getEventRef(id: UInt64): &FLOATEvent {
            return &self.events[id] as &FLOATEvent
        }

        // Get a public reference to the FLOATEvent
        // so you can call some helpful getters
        pub fun getPublicEventRef(id: UInt64): &FLOATEvent{FLOATEventPublic} {
            return &self.events[id] as &FLOATEvent{FLOATEventPublic}
        }

        pub fun borrowViewResolver(id: UInt64): &{MetadataViews.Resolver} {
            let floatRef = self.getEventRef(id: id)
            return floatRef as &{MetadataViews.Resolver}
        }

        pub fun getIDs(): [UInt64] {
            return self.events.keys
        }

        // Return all the FLOATEvents.
        pub fun getAllEvents(): {String: UInt64} {
            return self.nameToId
        }

        /*************************************** SHARED MINTER ***************************************/

        // A method for getting access to a shared minter. This is if 
        // a different account wants you to be able to handle their FLOAT Events
        // for them, so imagine if you're on a team of people and you all handle
        // one account.
        //
        // Will only be called by `giveSharing` below.
        access(account) fun receiveSharing(fromHost: &FLOATEvents) {
            // Allows you to mint for them
            self.canMintForThem.insert(key: fromHost.owner!.address, true)
        }

        // A method for giving a shared minter to somebody else.
        pub fun giveSharing(toHost: &FLOATEvents{FLOATEventsPublic}) {
            // Gives `toHost` the ability to mint for you
            toHost.receiveSharing(fromHost: self.getRef())
            self.canMintForMe.insert(key: toHost.owner!.address, true)
        }

        // A helper function, exposed to the public, but only callable
        // in the code defined here. Helps to handle the other host's
        // records so they know they can't mint for you anymore.
        access(account) fun removeSharing(ofHost: &FLOATEvents) {
            self.canMintForThem.remove(key: ofHost.owner!.address)
        }

        // Removes someone else from being able to handle your FLOAT Events.
        pub fun takeSharing(fromHost: Address) {
            // If for some reason they unlink their Collection from the public,
            // we can still remove them from ours.
            if let fromHostEvents = getAccount(fromHost).getCapability(FLOAT.FLOATEventsPublicPath).borrow<&FLOATEvents{FLOATEventsPublic}>() {
                fromHostEvents.removeSharing(ofHost: self.getRef())
            }
            self.canMintForMe.remove(key: fromHost)
        }

        // If you don't like them for some reason... lol
        pub fun removeHostFromMintForThem(host: Address) {
            self.canMintForThem.remove(key: host)
        }

        // Return a reference to someone elses FLOAT Events.
        // This will only ever work if you are in THEIR
        // `canMintForMe` dictionary.
        pub fun getSharedMinterRef(host: Address): &FLOATEvents? {
            let floatEvents = getAccount(host).getCapability(FLOAT.FLOATEventsPublicPath)
                                .borrow<&FLOATEvents{FLOATEventsPublic, FLOATEventsSharedMinter}>()
                                ?? panic("Could not borrow the public FLOAT Events.")

            if floatEvents.getAddressWhoCanMintForMe().contains(self.owner!.address) {
                return floatEvents.getRef()
            }
            return nil
        }

        access(account) fun getRef(): &FLOATEvents {
            return &self as &FLOATEvents
        }

        // Get a list of accounts you have
        // access to.
        pub fun getAddressWhoICanMintFor(): [Address] {
            return self.canMintForThem.keys
        }

        // Get a list of accounts you have allowed
        // to mint for you.
        pub fun getAddressWhoCanMintForMe(): [Address] {
            return self.canMintForMe.keys
        }

        /*************************************** CLAIMING ***************************************/

        // Allows the event host to distribute directly, regardless of whether or not
        // the event is claimable.
        pub fun distributeDirectly(id: UInt64, recipient: &Collection{NonFungibleToken.CollectionPublic} ) {
            pre {
                self.events[id] != nil:
                    "This event does not exist."
            }
            let FLOATEvent = self.getEventRef(id: id)
            FLOATEvent.mint(recipient: recipient)
        }

        // For the public to claim FLOATs. Must be claimable to do so.
        // The `secret` parameter is only necessary if you're claiming a `Secret` FLOAT.
        // Available to the public.
        pub fun claim(id: UInt64, recipient: &Collection, secret: String?) {
            pre {
                self.getEventRef(id: id).claimable: 
                    "This FLOATEvent is not claimable."
            }
            let FLOATEvent: &FLOATEvent = self.getEventRef(id: id)
            
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
                Limited.verify(currentCapacity: FLOATEvent.totalSupply)
            }

            emit FLOATClaimed(
                eventHost: FLOATEvent.host, 
                eventId: FLOATEvent.id, 
                eventImage: FLOATEvent.image,
                eventName: FLOATEvent.name,
                recipient: recipient.owner!.address,
                serial: FLOATEvent.totalSupply
            )

            // You have passed all the props (which act as restrictions).
            FLOATEvent.mint(recipient: recipient)
        }

        /******************************************************************************/

        init() {
            self.nameToId = {}
            self.events <- {}
            self.canMintForThem = {}
            self.canMintForMe = {}
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

        self.FLOATCollectionStoragePath = /storage/FLOATCollectionStoragePath018
        self.FLOATCollectionPublicPath = /public/FLOATCollectionPublicPath018
        self.FLOATEventsStoragePath = /storage/FLOATEventsStoragePath018
        self.FLOATEventsPrivatePath = /private/FLOATEventsPrivatePath018
        self.FLOATEventsPublicPath = /public/FLOATEventsPublicPath018
    }
}