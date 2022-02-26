import FLOATMetadataViews from "./FLOATMetadataViews.cdc"
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

    pub resource NFT: NonFungibleToken.INFT, MetadataViews.Resolver {
        // The `uuid` of this resource
        pub let id: UInt64

        pub let dateReceived: UFix64
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
        pub let eventsCap: Capability<&FLOATEvents{FLOATEventsPublic}>
        
        // Helper function to get the metadata of the event 
        // this FLOAT is from.
        pub fun getEventMetadata(): &FLOATEvent{FLOATEventPublic}? {
            let floatEvents = self.eventsCap.borrow() 
            return floatEvents?.borrowPublicEventRef(eventId: self.eventId)
        }

        pub fun getViews(): [Type] {
             return [
                Type<MetadataViews.Display>(),
                Type<FLOATMetadataViews.TokenIdentifier>()
            ]
        }

        pub fun resolveView(_ view: Type): AnyStruct? {
            switch view {
                case Type<MetadataViews.Display>():
                    let eventMetadata = self.getEventMetadata()
                    if eventMetadata != nil {
                        return MetadataViews.Display(
                            name: self.eventName, 
                            description: eventMetadata!.description, 
                            file: MetadataViews.IPFSFile(cid: self.eventImage, path: nil)
                        )
                    } else {
                         return MetadataViews.Display(
                            name: self.eventName, 
                            description: "", 
                            file: MetadataViews.IPFSFile(cid: self.eventImage, path: nil)
                        )
                    }
                case Type<FLOATMetadataViews.TokenIdentifier>():
                    return FLOATMetadataViews.TokenIdentifier(
                        id: self.id, 
                        address: self.owner!.address,
                        serial: self.serial
                    ) 
            }

            return nil
        }

        init(_eventHost: Address, _eventId: UInt64, _eventImage: String, _eventName: String, _originalRecipient: Address, _serial: UInt64) {
            self.id = self.uuid
            self.dateReceived = getCurrentBlock().timestamp
            self.eventHost = _eventHost
            self.eventId = _eventId
            self.eventImage = _eventImage
            self.eventName = _eventName
            self.originalRecipient = _originalRecipient
            self.serial = _serial

            self.eventsCap = getAccount(_eventHost)
                .getCapability<&FLOATEvents{FLOATEventsPublic}>(FLOAT.FLOATEventsPublicPath)
            
            emit FLOATMinted(
                id: self.id, 
                eventHost: self.eventHost, 
                eventId: self.eventId, 
                eventImage: self.eventImage,
                recipient: self.originalRecipient,
                serial: self.serial
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

    pub resource interface CollectionPublic {
        pub fun deposit(token: @NonFungibleToken.NFT)
        pub fun getIDs(): [UInt64]
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
        pub fun borrowFLOAT(id: UInt64): &NFT
    }

    // A collectiont that holds all of the users FLOATs.
    // Withdrawing is not allowed. You can only transfer.
    pub resource Collection: NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection, CollectionPublic {
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

        pub fun deposit(token: @NonFungibleToken.NFT) {
            let nft <- token as! @NFT
            emit FLOATDeposited(id: nft.id, to: self.owner!.address, )
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

        // Only returns NFT IDs for which
        // you can still view event metadata
        // from (meaning the event host didn't
        // unlink their FLOATEvents resource to
        // the public)
        pub fun getIDs(): [UInt64] {
            let ids = self.ownedNFTs.keys
            let answer: [UInt64] = []
            for id in ids {
                let tokenRef = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
                let nftRef = tokenRef as! &NFT
                if nftRef.eventsCap.check() {
                    answer.append(id)
                }
            }
            return answer
        }

        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return &self.ownedNFTs[id] as &NonFungibleToken.NFT
        }

        pub fun borrowFLOAT(id: UInt64): &NFT {
            let ref = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
            return ref as! &NFT
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
        // Modules that are currently activated,
        // meaning acting as walls for the user
        // to be able to claim.
        pub fun activatedModules(): [Type]

        // True if the user is somehow able to
        // get to claiming the FLOAT at this moment.
        //
        // Examples:
        // If the current time is within the
        // time limit, it's not at capacity, but they have
        // to type in a secret code, this would be true.
        // 
        // If the event hasn't started yet or is
        // at capacity, this would be false.
        pub fun canAttemptClaim(event: &FLOATEvent{FLOATEventPublic}): Bool

        // A function every verifier must implement. Returns a bool
        // if all checks pass, meaning the user can be minted a FLOAT.
        access(account) fun verify(event: &FLOATEvent{FLOATEventPublic}, _ params: {String: AnyStruct}): Bool
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
        pub let verifier: {IVerifier}
        pub fun getClaimed(): {Address: FLOATMetadataViews.TokenIdentifier}
        pub fun getCurrentHolders(): {UInt64: FLOATMetadataViews.TokenIdentifier}
        pub fun getExtraMetadata(): {String: String}
        pub fun hasClaimed(account: Address): FLOATMetadataViews.TokenIdentifier?
        pub fun getCurrentHolder(serial: UInt64): FLOATMetadataViews.TokenIdentifier?
        pub fun claim(recipient: &Collection, params: {String: AnyStruct})
    }

    //
    // FLOATEvent
    //
    pub resource FLOATEvent: FLOATEventPublic {
        // A manual toggle the event host can turn
        // on and off to stop claiming
        pub var claimable: Bool
        // Maps the address of the person who claimed
        // the FLOAT to:
        /*
        { 
            id: uuid of the FLOAT
            serial: serial of the FLOAT
            address: original recipient (or "claimer")
        }
        */
        access(account) var claimed: {Address: FLOATMetadataViews.TokenIdentifier}
        // Maps the serial of the FLOAT to:
        /*
        { 
            id: uuid of the FLOAT
            serial: serial of the FLOAT
            address: current holder
        } 
        */ 
        access(account) var currentHolders: {UInt64: FLOATMetadataViews.TokenIdentifier}
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
        pub let verifier: {IVerifier}

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
            self.currentHolders[serial] = FLOATMetadataViews.TokenIdentifier(
                id: id,
                address: to,
                serial: serial
            )
        }

        // Called if a user deletes their FLOAT.
        // Removes the FLOAT's serial from the 
        // `currentHolders` dictionary.
        access(account) fun accountDeletedFLOAT(serial: UInt64) {
            self.currentHolders.remove(key: serial)
        }

        /***************** Getters (all exposed to the public) *****************/

        pub fun hasClaimed(account: Address): FLOATMetadataViews.TokenIdentifier? {
            return self.claimed[account]
        }

        pub fun getCurrentHolder(serial: UInt64): FLOATMetadataViews.TokenIdentifier? {
            return self.currentHolders[serial]
        }

        pub fun getExtraMetadata(): {String: String} {
            return self.extraMetadata
        }

        pub fun getClaimed(): {Address: FLOATMetadataViews.TokenIdentifier} {
            return self.claimed
        }

        pub fun getCurrentHolders(): {UInt64: FLOATMetadataViews.TokenIdentifier} {
            return self.currentHolders
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
                _eventHost: self.host, 
                _eventId: self.eventId,
                _eventImage: self.image,
                _eventName: self.name,
                _originalRecipient: recipientAddr, 
                _serial: serial
            ) 
            let id = token.id
            self.claimed[recipientAddr] = FLOATMetadataViews.TokenIdentifier(
                _id: id,
                _address: recipientAddr,
                _serial: serial
            )
            self.currentHolders[serial] = FLOATMetadataViews.TokenIdentifier(
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
            
            if !self.verifier.verify(event: &self as &FLOATEvent{FLOATEventPublic}, params) {
                panic("You did not meet some requirement in order to claim.")
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
            _verifier: {IVerifier},
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
            
            self.verifier = _verifier

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
        pub fun borrowPublicEventRef(eventId: UInt64): &FLOATEvent{FLOATEventPublic}
        pub fun getAllEvents(): {String: UInt64}
        pub fun getAddressWhoICanMintFor(): [Address]
        pub fun getAddressWhoCanMintForMe(): [Address]
        pub fun getIDs(): [UInt64]
        // Account Setters
        access(account) fun createEvent(claimable: Bool, description: String, image: String, name: String, transferrable: Bool, url: String, verifier: {IVerifier}, _ extraMetadata: {String: String}): UInt64
        access(account) fun receiveSharing(fromHost: Address) 
        access(account) fun removeSharing(ofHost: Address)
        // Account Getters
        access(account) fun borrowEventRef(eventId: UInt64): &FLOATEvent
    }

    pub resource FLOATEvents: FLOATEventsPublic {
        // Makes sure a name is only being used once for every account.
        access(account) var nameToId: {String: UInt64}
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
            verifier: {IVerifier},
            _ extraMetadata: {String: String}
        ): UInt64 {
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
                _name: name, 
                _transferrable: transferrable,
                _url: url,
                _verifier: verifier
            )
            let eventId = FLOATEvent.eventId
            self.nameToId[FLOATEvent.name] = eventId
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
            let name: String = self.borrowEventRef(eventId: eventId).name

            self.nameToId.remove(key: name)
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

        pub fun getAllEvents(): {String: UInt64} {
            return self.nameToId
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
            verifier: {IVerifier},
            _ extraMetadata: {String: String}
        ) {
            let floatEvents = getAccount(forHost).getCapability(FLOAT.FLOATEventsPublicPath)
                                .borrow<&FLOATEvents{FLOATEventsPublic}>() 
                                ?? panic("Cannot borrow the public FLOAT Events from forHost")
            assert(
                floatEvents.getAddressWhoCanMintForMe().contains(self.owner!.address), 
                message: "You cannot mint for this host."
            )
            let eventId = floatEvents.createEvent(claimable: claimable, description: description, image: image, name: name, transferrable: transferrable, url: url, verifier: verifier, extraMetadata)
            emit FLOATEventCreatedBySharedMinter(forHost: forHost, bySharedMinter: self.owner!.address, eventId: eventId)
        }

        // ACCESSIBLE BY: Owner
        pub fun turnOffSharedMinting(): Bool {
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
            self.nameToId = {}
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

        self.FLOATCollectionStoragePath = /storage/FLOATCollectionStoragePath025
        self.FLOATCollectionPublicPath = /public/FLOATCollectionPublicPath025
        self.FLOATEventsStoragePath = /storage/FLOATEventsStoragePath025
        self.FLOATEventsPrivatePath = /private/FLOATEventsPrivatePath025
        self.FLOATEventsPublicPath = /public/FLOATEventsPublicPath025
    }
}