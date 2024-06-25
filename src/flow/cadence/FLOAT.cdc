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

import NonFungibleToken from "./utility/NonFungibleToken.cdc"
import MetadataViews from "./utility/MetadataViews.cdc"
import FungibleToken from "./utility/FungibleToken.cdc"
import FlowToken from "./utility/FlowToken.cdc"
import FindViews from "./utility/FindViews.cdc"
import ViewResolver from "./utility/ViewResolver.cdc"

pub contract FLOAT: NonFungibleToken, ViewResolver {

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
    pub event FLOATDestroyed(id: UInt64, eventHost: Address, eventId: UInt64, eventImage: String, serial: UInt64)
    pub event FLOATTransferred(id: UInt64, eventHost: Address, eventId: UInt64, newOwner: Address?, serial: UInt64)
    pub event FLOATPurchased(id: UInt64, eventHost: Address, eventId: UInt64, recipient: Address, serial: UInt64)
    pub event FLOATEventCreated(eventId: UInt64, description: String, host: Address, image: String, name: String, url: String)
    pub event FLOATEventDestroyed(eventId: UInt64, host: Address, name: String)

    pub event Deposit(id: UInt64, to: Address?)
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

    pub struct TokenInfo {
        pub let path: PublicPath
        pub let price: UFix64

        init(_path: PublicPath, _price: UFix64) {
            self.path = _path
            self.price = _price
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
        pub fun getEventRef(): &FLOATEvent{FLOATEventPublic}? {
            if let events: &FLOATEvents{FLOATEventsPublic, MetadataViews.ResolverCollection} = self.eventsCap.borrow() {
                return events.borrowPublicEventRef(eventId: self.eventId)
            }
            return nil
        }

        pub fun getExtraMetadata(): {String: AnyStruct} {
            if let event: &FLOATEvent{FLOATEventPublic} = self.getEventRef() {
                return event.getExtraFloatMetadata(serial: self.serial)
            }
            return {}
        }

        pub fun getSpecificExtraMetadata(key: String): AnyStruct? {
            return self.getExtraMetadata()[key]
        }

        pub fun getImage(): String {
            if let extraEventMetadata: {String: AnyStruct} = self.getEventRef()?.getExtraMetadata() {
                if FLOAT.extraMetadataToStrOpt(extraEventMetadata, "visibilityMode") == "picture" {
                    return self.eventImage
                }
                if let certificateType: String = FLOAT.extraMetadataToStrOpt(extraEventMetadata, "certificateType") {
                    if certificateType == "medal" {
                         // Extra metadata about medal colors
                        if let medalType: String = FLOAT.extraMetadataToStrOpt(self.getExtraMetadata(), "medalType") {
                            return FLOAT.extraMetadataToStrOpt(extraEventMetadata, "certificateImage.".concat(medalType)) ?? self.eventImage
                        }
                        // if there is no medal type for the FLOAT
                        return FLOAT.extraMetadataToStrOpt(extraEventMetadata, "certificateImage.participation") ?? self.eventImage
                    }
                    return FLOAT.extraMetadataToStrOpt(extraEventMetadata, "certificateImage") ?? self.eventImage
                }
            }
            return self.eventImage
        }

        // This is for the MetdataStandard
        pub fun getViews(): [Type] {
            let supportedViews = [
                Type<MetadataViews.Display>(),
                Type<MetadataViews.Royalties>(),
                Type<MetadataViews.ExternalURL>(),
                Type<MetadataViews.NFTCollectionData>(),
                Type<MetadataViews.NFTCollectionDisplay>(),
                Type<MetadataViews.Traits>(),
                Type<MetadataViews.Serial>(),
                Type<TokenIdentifier>()
            ]

            if self.getEventRef()?.transferrable == false {
                supportedViews.append(Type<FindViews.SoulBound>())
            }

            return supportedViews
        }

        // This is for the MetdataStandard
        pub fun resolveView(_ view: Type): AnyStruct? {
            switch view {
                case Type<MetadataViews.Display>():
                    return MetadataViews.Display(
                        name: self.eventName, 
                        description: self.eventDescription, 
                        thumbnail: MetadataViews.HTTPFile(url: "https://ipfs.io/ipfs/".concat(self.getImage()))
                    )
                case Type<MetadataViews.Royalties>():
                    return MetadataViews.Royalties([
						MetadataViews.Royalty(
							recepient: getAccount(0x5643fd47a29770e7).getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver),
							cut: 0.05, // 5% royalty on secondary sales
							description: "Emerald City DAO receives a 5% royalty from secondary sales because this NFT was created using FLOAT (https://floats.city/), a proof of attendance platform created by Emerald City DAO."
						)
					])
                case Type<MetadataViews.ExternalURL>():
                    return MetadataViews.ExternalURL("https://floats.city/".concat(self.owner!.address.toString()).concat("/float/").concat(self.id.toString()))
                case Type<MetadataViews.NFTCollectionData>():
                    return FLOAT.resolveView(view)
                case Type<MetadataViews.NFTCollectionDisplay>():
                    return FLOAT.resolveView(view)
                case Type<MetadataViews.Serial>():
                    return MetadataViews.Serial(
                        self.serial
                    )
                case Type<TokenIdentifier>():
                    return TokenIdentifier(
                        _id: self.id, 
                        _address: self.owner!.address,
                        _serial: self.serial
                    ) 
                case Type<FindViews.SoulBound>():
                    if self.getEventRef()?.transferrable == false {
                        return FindViews.SoulBound(
                            "This FLOAT is soulbound because the event host toggled off transferring."
                        )
                    }
                    return nil
                case Type<MetadataViews.Traits>():
                    let traitsView: MetadataViews.Traits = MetadataViews.dictToTraits(dict: self.getExtraMetadata(), excludedNames: nil)

                    if let eventRef: &FLOATEvent{FLOATEventPublic} = self.getEventRef() {
                        let eventExtraMetadata: {String: AnyStruct} = eventRef.getExtraMetadata()
                        
                        // certificate type doesn't apply if it's a picture FLOAT
                        if FLOAT.extraMetadataToStrOpt(eventExtraMetadata, "visibilityMode") == "certificate" {
                            let certificateType: MetadataViews.Trait = MetadataViews.Trait(name: "certificateType", value: eventExtraMetadata["certificateType"], displayType: nil, rarity: nil)
                            traitsView.addTrait(certificateType)
                        }
                        
                        let serial: MetadataViews.Trait = MetadataViews.Trait(name: "serial", value: self.serial, displayType: nil, rarity: nil)
                        traitsView.addTrait(serial)
                        let originalRecipient: MetadataViews.Trait = MetadataViews.Trait(name: "originalRecipient", value: self.originalRecipient, displayType: nil, rarity: nil)
                        traitsView.addTrait(originalRecipient)
                        let eventCreator: MetadataViews.Trait = MetadataViews.Trait(name: "eventCreator", value: self.eventHost, displayType: nil, rarity: nil)
                        traitsView.addTrait(eventCreator)
                        let eventType: MetadataViews.Trait = MetadataViews.Trait(name: "eventType", value: eventExtraMetadata["eventType"], displayType: nil, rarity: nil)
                        traitsView.addTrait(eventType)
                        let dateReceived: MetadataViews.Trait = MetadataViews.Trait(name: "dateMinted", value: self.dateReceived, displayType: "Date", rarity: nil)
                        traitsView.addTrait(dateReceived)
                        let eventId: MetadataViews.Trait = MetadataViews.Trait(name: "eventId", value: self.eventId, displayType: nil, rarity: nil)
                        traitsView.addTrait(eventId)
                    }

                    return traitsView
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

        destroy() {
            emit FLOATDestroyed(
                id: self.id, 
                eventHost: self.eventHost, 
                eventId: self.eventId, 
                eventImage: self.eventImage,
                serial: self.serial
            )
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
    }

    // A Collection that holds all of the users FLOATs.
    // Withdrawing is not allowed. You can only transfer.
    pub resource Collection: NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection, CollectionPublic {
        // Maps a FLOAT id to the FLOAT itself
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}
        // Maps an eventId to the ids of FLOATs that
        // this user owns from that event. It's possible
        // for it to be out of sync until June 2022 spork, 
        // but it is used merely as a helper, so that's okay.
        access(self) var events: {UInt64: {UInt64: Bool}}

        // Deposits a FLOAT to the collection
        pub fun deposit(token: @NonFungibleToken.NFT) {
            let nft <- token as! @NFT
            let id = nft.id
            let eventId = nft.eventId
        
            // Update self.events[eventId] to have
            // this FLOAT's id in it
            if self.events[eventId] == nil {
                self.events[eventId] = {id: true}
            } else {
                self.events[eventId]!.insert(key: id, true)
            }

            emit Deposit(id: id, to: self.owner?.address)
            emit FLOATTransferred(id: id, eventHost: nft.eventHost, eventId: nft.eventId, newOwner: self.owner?.address, serial: nft.serial)
            self.ownedNFTs[id] <-! nft
        }

        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("You do not own this FLOAT in your collection")
            let nft <- token as! @NFT

            // Update self.events[eventId] to not
            // have this FLOAT's id in it
            self.events[nft.eventId]!.remove(key: withdrawID)

            // This checks if the FLOATEvent host wanted this
            // FLOAT to be transferrable. Secondary marketplaces will use this
            // withdraw function, so if the FLOAT is not transferrable,
            // you can't sell it there.
            if let floatEvent: &FLOATEvent{FLOATEventPublic} = nft.getEventRef() {
                assert(
                    floatEvent.transferrable, 
                    message: "This FLOAT is not transferrable."
                )
            }

            emit Withdraw(id: withdrawID, from: self.owner?.address) 
            emit FLOATTransferred(id: withdrawID, eventHost: nft.eventHost, eventId: nft.eventId, newOwner: nil, serial: nft.serial)
            return <- nft
        }

        pub fun delete(id: UInt64) {
            let token <- self.ownedNFTs.remove(key: id) ?? panic("You do not own this FLOAT in your collection")
            let nft <- token as! @NFT

            // Update self.events[eventId] to not
            // have this FLOAT's id in it
            self.events[nft.eventId]!.remove(key: id)

            destroy nft
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
        //
        // It's possible for FLOAT ids to be present that
        // shouldn't be if people tried to withdraw directly
        // from `ownedNFTs` (not possible after June 2022 spork), 
        // but this makes sure the returned
        // ids are all actually owned by this account.
        pub fun ownedIdsFromEvent(eventId: UInt64): [UInt64] {
            let answer: [UInt64] = []
            if let idsInEvent = self.events[eventId]?.keys {
                for id in idsInEvent {
                    if self.ownedNFTs[id] != nil {
                        answer.append(id)
                    }
                }
            }
            return answer
        }

        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return (&self.ownedNFTs[id] as &NonFungibleToken.NFT?)!
        }

        pub fun borrowFLOAT(id: UInt64): &NFT? {
            if self.ownedNFTs[id] != nil {
                let ref = (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)!
                return ref as! &NFT
            }
            return nil
        }

        pub fun borrowViewResolver(id: UInt64): &{MetadataViews.Resolver} {
            let tokenRef = (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)!
            let nftRef = tokenRef as! &NFT
            return nftRef as &{MetadataViews.Resolver}
        }

        init() {
            self.ownedNFTs <- {}
            self.events = {}
        }

        destroy() {
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
        pub fun purchase(recipient: &Collection, params: {String: AnyStruct}, payment: @FungibleToken.Vault)

        pub fun getExtraMetadata(): {String: AnyStruct}
        pub fun getSpecificExtraMetadata(key: String): AnyStruct?
        pub fun getVerifiers(): {String: [{IVerifier}]}
        pub fun getPrices(): {String: TokenInfo}?
        pub fun getExtraFloatMetadata(serial: UInt64): {String: AnyStruct}
        pub fun getSpecificExtraFloatMetadata(serial: UInt64, key: String): AnyStruct?
        pub fun getClaims(): {UInt64: TokenIdentifier}
        pub fun getSerialsUserClaimed(address: Address): [UInt64]
        pub fun userHasClaimed(address: Address): Bool
        pub fun userCanMint(address: Address): Bool
    }

    //
    // FLOATEvent
    //
    pub resource FLOATEvent: FLOATEventPublic, MetadataViews.Resolver {
        // Whether or not users can claim from our event (can be toggled
        // at any time)
        pub var claimable: Bool
        pub let dateCreated: UFix64
        pub let description: String 
        // This is equal to this resource's uuid
        pub let eventId: UInt64
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
        // from this event can be transferred on the
        // FLOAT platform itself (transferring allowed
        // elsewhere)
        pub var transferrable: Bool
        // A url of where the event took place
        pub let url: String
        // A list of verifiers this FLOAT Event contains.
        // Will be used every time someone "claims" a FLOAT
        // to see if they pass the requirements
        access(self) let verifiers: {String: [{IVerifier}]}
        // Used to store extra metadata about the event but
        // also individual FLOATs, because Jacob forgot to
        // put a dictionary in the NFT resource :/ Idiot
        access(self) var extraMetadata: {String: AnyStruct}

        // DEPRECATED, DO NOT USE
        access(self) var claimed: {Address: TokenIdentifier}
        // DEPRECATED, DO NOT USE (used for storing claim info now)
        access(self) var currentHolders: {UInt64: TokenIdentifier}
        // DEPRECATED, DO NOT USE
        access(self) var groups: {String: Bool}

        // Type: Admin Toggle
        pub fun toggleClaimable(): Bool {
            self.claimable = !self.claimable
            return self.claimable
        }

        // Type: Admin Toggle
        pub fun toggleTransferrable(): Bool {
            self.transferrable = !self.transferrable
            return self.transferrable
        }

        // Type: Admin Toggle
        pub fun toggleVisibilityMode() {
            if let currentVisibilityMode: String = FLOAT.extraMetadataToStrOpt(self.getExtraMetadata(), "visibilityMode") {
                if currentVisibilityMode == "certificate" {
                    self.extraMetadata["visibilityMode"] = "picture"
                    return
                }
            }
            self.extraMetadata["visibilityMode"] = "certificate"
        }

        // Type: Contract Setter
        access(self) fun setUserClaim(serial: UInt64, address: Address, floatId: UInt64) {
            self.currentHolders[serial] = TokenIdentifier(_id: floatId, _address: address, _serial: serial)

            if self.extraMetadata["userClaims"] == nil {
                let userClaims: {Address: [UInt64]} = {}
                self.extraMetadata["userClaims"] = userClaims
            }
            let e = (&self.extraMetadata["userClaims"] as auth &AnyStruct?)!
            let claims = e as! &{Address: [UInt64]}

            if let specificUserClaims: [UInt64] = claims[address] {
                claims[address]!.append(serial)
            } else {
                claims[address] = [serial]
            }
        }

        // Type: Contract Setter
        access(self) fun setExtraFloatMetadata(serial: UInt64, metadata: {String: AnyStruct}) {
            if self.extraMetadata["extraFloatMetadatas"] == nil {
                let extraFloatMetadatas: {UInt64: AnyStruct} = {}
                self.extraMetadata["extraFloatMetadatas"] = extraFloatMetadatas
            }
            let e = (&self.extraMetadata["extraFloatMetadatas"] as auth &AnyStruct?)!
            let extraFloatMetadatas = e as! &{UInt64: AnyStruct}
            extraFloatMetadatas[serial] = metadata
        }

        // Type: Contract Setter
        access(self) fun setSpecificExtraFloatMetadata(serial: UInt64, key: String, value: AnyStruct) {
            if self.extraMetadata["extraFloatMetadatas"] == nil {
                let extraFloatMetadatas: {UInt64: AnyStruct} = {}
                self.extraMetadata["extraFloatMetadatas"] = extraFloatMetadatas
            }
            let e = (&self.extraMetadata["extraFloatMetadatas"] as auth &AnyStruct?)!
            let extraFloatMetadatas = e as! &{UInt64: AnyStruct}

            if extraFloatMetadatas[serial] == nil {
                let extraFloatMetadata: {String: AnyStruct} = {}
                extraFloatMetadatas[serial] = extraFloatMetadata
            }

            let f = (&extraFloatMetadatas[serial] as auth &AnyStruct?)!
            let extraFloatMetadata = e as! &{String: AnyStruct}
            extraFloatMetadata[key] = value
        }

        // Type: Getter
        // Description: Get extra metadata on a specific FLOAT from this event
        pub fun getExtraFloatMetadata(serial: UInt64): {String: AnyStruct} {
            if self.extraMetadata["extraFloatMetadatas"] != nil {
                if let e: {UInt64: AnyStruct} = self.extraMetadata["extraFloatMetadatas"]! as? {UInt64: AnyStruct} {
                    if e[serial] != nil {
                        if let f: {String: AnyStruct} = e[serial]! as? {String: AnyStruct} {
                            return f
                        }
                    }
                }
            }
            return {}
        }

        // Type: Getter
        // Description: Get specific extra metadata on a specific FLOAT from this event
        pub fun getSpecificExtraFloatMetadata(serial: UInt64, key: String): AnyStruct? {
            return self.getExtraFloatMetadata(serial: serial)[key]
        }

        // Type: Getter
        // Description: Returns claim info of all the serials
        pub fun getClaims(): {UInt64: TokenIdentifier} {
            return self.currentHolders
        }

        // Type: Getter
        // Description: Will return an array of all the serials a user claimed.  
        // Most of the time this will be a maximum length of 1 because most 
        // events only allow 1 claim per user.
        pub fun getSerialsUserClaimed(address: Address): [UInt64] {
            var serials: [UInt64] = []
            if let userClaims: {Address: [UInt64]} = self.getSpecificExtraMetadata(key: "userClaims") as! {Address: [UInt64]}? {
                serials = userClaims[address] ?? []
            }
            // take into account claims during FLOATv1
            if let oldClaim: TokenIdentifier = self.claimed[address] {
                serials.append(oldClaim.serial)
            }
            return serials
        }

        // Type: Getter
        // Description: Returns true if the user has either claimed
        // or been minted at least one float from this event
        pub fun userHasClaimed(address: Address): Bool {
            return self.getSerialsUserClaimed(address: address).length >= 1
        }

        // Type: Getter
        // Description: Get extra metadata on this event
        pub fun getExtraMetadata(): {String: AnyStruct} {
            return self.extraMetadata
        }

        // Type: Getter
        // Description: Get specific extra metadata on this event
        pub fun getSpecificExtraMetadata(key: String): AnyStruct? {
            return self.extraMetadata[key]
        }

        // Type: Getter
        // Description: Checks if a user can mint a new FLOAT from this event
        pub fun userCanMint(address: Address): Bool {
            if let allows: Bool = self.getSpecificExtraMetadata(key: "allowMultipleClaim") as! Bool? {
                if allows || self.getSerialsUserClaimed(address: address).length == 0 {
                    return true
                }
            }
            return !self.userHasClaimed(address: address)
        }

        // Type: Getter
        // Description: Gets all the verifiers that will be used
        // for claiming
        pub fun getVerifiers(): {String: [{IVerifier}]} {
            return self.verifiers
        }

        // Type: Getter
        // Description: Returns a dictionary whose key is a token identifier
        // and value is the path to that token and price of the FLOAT in that
        // currency
        pub fun getPrices(): {String: TokenInfo}? {
            return self.extraMetadata["prices"] as! {String: TokenInfo}?
        }

        // Type: Getter
        // Description: For MetadataViews
        pub fun getViews(): [Type] {
             return [
                Type<MetadataViews.Display>()
            ]
        }

        // Type: Getter
        // Description: For MetadataViews
        pub fun resolveView(_ view: Type): AnyStruct? {
            switch view {
                case Type<MetadataViews.Display>():
                    return MetadataViews.Display(
                        name: self.name, 
                        description: self.description, 
                        thumbnail: MetadataViews.IPFSFile(cid: self.image, path: nil)
                    )
            }

            return nil
        }

        // Type: Admin / Helper Function for `verifyAndMint`
        // Description: Used to give a person a FLOAT from this event.
        // If the event owner directly mints to a user, it does not
        // run the verifiers on the user. It bypasses all of them.
        // Return the id of the FLOAT it minted.
        pub fun mint(recipient: &Collection{NonFungibleToken.CollectionPublic}, optExtraFloatMetadata: {String: AnyStruct}?): UInt64 {
            pre {
                self.userCanMint(address: recipient.owner!.address): "Only 1 FLOAT allowed per user, and this user already claimed their FLOAT!"
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

            if let extraFloatMetadata: {String: AnyStruct} = optExtraFloatMetadata {
                // ensure 
                assert(
                    FLOAT.validateExtraFloatMetadata(data: extraFloatMetadata), 
                    message: "Extra FLOAT metadata is not proper. Check the `FLOAT.validateExtraFloatMetadata` function."
                )
                self.setExtraFloatMetadata(serial: serial, metadata: extraFloatMetadata)
            }

            let id: UInt64 = token.id

            self.setUserClaim(serial: serial, address: recipientAddr, floatId: id)

            self.totalSupply = self.totalSupply + 1
            recipient.deposit(token: <- token)
            return id
        }

        // Type: Helper Function for `claim` and `purchase`
        // Description: Will get run by the public, so verifies
        // the user can mint
        access(self) fun verifyAndMint(recipient: &Collection, params: {String: AnyStruct}): UInt64 {
            params["event"] = &self as &FLOATEvent{FLOATEventPublic}
            params["claimee"] = recipient.owner!.address
            
            // Runs a loop over all the verifiers that this FLOAT Events
            // implements. For example, "Limited", "Timelock", "Secret", etc.  
            // All the verifiers are in the FLOATVerifiers.cdc contract
            for identifier in self.verifiers.keys {
                let typedModules = (&self.verifiers[identifier] as &[{IVerifier}]?)!
                var i = 0
                while i < typedModules.length {
                    let verifier = &typedModules[i] as &{IVerifier}
                    verifier.verify(params)
                    i = i + 1
                }
            }

            var optExtraFloatMetadata: {String: AnyStruct}? = nil
            // if this is a medal type float and user is publicly claiming, assign to participation
            if FLOAT.extraMetadataToStrOpt(self.getExtraMetadata(), "certificateType") == "medal" {
                optExtraFloatMetadata = {"medalType": "participation"}
            }

            // You're good to go.
            let id: UInt64 = self.mint(recipient: recipient, optExtraFloatMetadata: optExtraFloatMetadata)

            emit FLOATClaimed(
                id: id,
                eventHost: self.host, 
                eventId: self.eventId, 
                eventImage: self.image,
                eventName: self.name,
                recipient: recipient.owner!.address,
                serial: self.totalSupply - 1
            )
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
                self.getPrices() == nil:
                    "You need to purchase this FLOAT."
                self.claimable: 
                    "This FLOAT event is not claimable, and thus not currently active."
            }
            
            self.verifyAndMint(recipient: recipient, params: params)
        }
 
        pub fun purchase(recipient: &Collection, params: {String: AnyStruct}, payment: @FungibleToken.Vault) {
            pre {
                self.getPrices() != nil:
                    "Don't call this function. The FLOAT is free. Call the claim function instead."
                self.getPrices()![payment.getType().identifier] != nil:
                    "This FLOAT does not support purchasing in the passed in token."
                payment.balance == self.getPrices()![payment.getType().identifier]!.price:
                    "You did not pass in the correct amount of tokens."
                self.claimable: 
                    "This FLOAT event is not claimable, and thus not currently active."
            }
            let royalty: UFix64 = 0.05
            let emeraldCityTreasury: Address = 0x5643fd47a29770e7
            let paymentType: String = payment.getType().identifier
            let tokenInfo: TokenInfo = self.getPrices()![paymentType]!

            let EventHostVault = getAccount(self.host).getCapability(tokenInfo.path)
                                    .borrow<&{FungibleToken.Receiver}>()
                                    ?? panic("Could not borrow the &{FungibleToken.Receiver} from the event host.")

            assert(
                EventHostVault.getType().identifier == paymentType,
                message: "The event host's path is not associated with the intended token."
            )
            
            let EmeraldCityVault = getAccount(emeraldCityTreasury).getCapability(tokenInfo.path)
                                    .borrow<&{FungibleToken.Receiver}>() 
                                    ?? panic("Could not borrow the &{FungibleToken.Receiver} from Emerald City's Vault.")

            assert(
                EmeraldCityVault.getType().identifier == paymentType,
                message: "Emerald City's path is not associated with the intended token."
            )

            let emeraldCityCut <- payment.withdraw(amount: payment.balance * royalty)

            EmeraldCityVault.deposit(from: <- emeraldCityCut)
            EventHostVault.deposit(from: <- payment)

            let id = self.verifyAndMint(recipient: recipient, params: params)

            emit FLOATPurchased(id: id, eventHost: self.host, eventId: self.eventId, recipient: recipient.owner!.address, serial: self.totalSupply - 1)
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
            _verifiers: {String: [{IVerifier}]}
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
            self.groups = {}

            FLOAT.totalFLOATEvents = FLOAT.totalFLOATEvents + 1
            emit FLOATEventCreated(eventId: self.eventId, description: self.description, host: self.host, image: self.image, name: self.name, url: self.url)
        }

        destroy() {
            emit FLOATEventDestroyed(eventId: self.eventId, host: self.host, name: self.name)
        }
    }

    // DEPRECATED
    pub resource Group {
        pub let id: UInt64
        pub let name: String
        pub let image: String
        pub let description: String
        access(self) var events: {UInt64: Bool}
        init() {
            self.id = 0
            self.name = ""
            self.image = ""
            self.description = ""
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
        pub fun borrowViewResolver(id: UInt64): &{MetadataViews.Resolver}
    }

    // A "Collection" of FLOAT Events
    pub resource FLOATEvents: FLOATEventsPublic, MetadataViews.ResolverCollection {
        // All the FLOAT Events this collection stores
        access(self) var events: @{UInt64: FLOATEvent}
        // DEPRECATED
        access(self) var groups: @{String: Group}

        // Creates a new FLOAT Event
        //
        // Read below for a description on all the values and expectations here
        //
        // claimable: Do you want this FLOAT to be publicly claimable by users?
        // transferrable: Should this FLOAT be transferrable or soulbound?
        // url: A generic url to your FLOAT Event
        // verifiers: An array of verifiers from FLOATVerifiers contract
        // allowMultipleClaim: Should users be able to claim/receive multiple
        // of this FLOAT?
        // certificateType: Determines how the FLOAT is displayed on the FLOAT platform. Must be one of the 
        // following or it will fail: "ticket", "medal", "certificate"
        // visibilityMode: Determines how the FLOAT is displayed on the FLOAT platform. Must be one of the 
        // following: "picture", "certificate"
        // extraMetadata: Any extra metadata for your event. Here are some restrictions on the keys of this dictionary:
            // userClaims: You cannot provide a userClaims key
            // extraFloatMetadatas: You cannot provide a extraFloatMetadatas key
            // certificateImage: Must either be nil or a String type
            // backImage: The IPFS CID of what will display on the back of your FLOAT. Must either be nil or a String type
            // eventType: Must either be nil or a String type
        pub fun createEvent(
            claimable: Bool,
            description: String,
            image: String, 
            name: String, 
            transferrable: Bool,
            url: String,
            verifiers: [{IVerifier}],
            allowMultipleClaim: Bool,
            certificateType: String,
            visibilityMode: String,
            extraMetadata: {String: AnyStruct}
        ): UInt64 {
            pre {
                certificateType == "ticket" || certificateType == "medal" || certificateType == "certificate": "You must either choose 'ticket', 'medal', or 'certificate' for certificateType. This is how your FLOAT will be displayed."
                visibilityMode == "certificate" || visibilityMode == "picture": "You must either choose 'certificate' or 'picture' for visibilityMode. This is how your FLOAT will be displayed."
                extraMetadata["userClaims"] == nil: "Cannot use userClaims key in extraMetadata."
                extraMetadata["extraFloatMetadatas"] == nil: "Cannot use extraFloatMetadatas key in extraMetadata."
                extraMetadata["certificateImage"] == nil || extraMetadata["certificateImage"]!.getType() == Type<String>(): "certificateImage must be a String or nil type."
                extraMetadata["backImage"] == nil || extraMetadata["backImage"]!.getType() == Type<String>(): "backImage must be a String or nil type."
                extraMetadata["eventType"] == nil || extraMetadata["eventType"]!.getType() == Type<String>(): "eventType must be a String or nil type."
            }

            let typedVerifiers: {String: [{IVerifier}]} = {}
            for verifier in verifiers {
                let identifier: String = verifier.getType().identifier
                if typedVerifiers[identifier] == nil {
                    typedVerifiers[identifier] = [verifier]
                } else {
                    typedVerifiers[identifier]!.append(verifier)
                }
            }

            extraMetadata["allowMultipleClaim"] = allowMultipleClaim
            extraMetadata["certificateType"] = certificateType
            extraMetadata["visibilityMode"] = visibilityMode

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
            let eventId: UInt64 = FLOATEvent.eventId
            self.events[eventId] <-! FLOATEvent

            return eventId
        }

        // Deletes an event.
        pub fun deleteEvent(eventId: UInt64) {
            let eventRef = self.borrowEventRef(eventId: eventId) ?? panic("This FLOAT does not exist.")
            destroy self.events.remove(key: eventId)
        }

        pub fun borrowEventRef(eventId: UInt64): &FLOATEvent? {
            return &self.events[eventId] as &FLOATEvent?
        }

        // Get a public reference to the FLOATEvent
        // so you can call some helpful getters
        pub fun borrowPublicEventRef(eventId: UInt64): &FLOATEvent{FLOATEventPublic}? {
            return &self.events[eventId] as &FLOATEvent{FLOATEventPublic}?
        }

        pub fun getIDs(): [UInt64] {
            return self.events.keys
        }

        // Maps the eventId to the name of that
        // event. Just a kind helper.
        pub fun getAllEvents(): {UInt64: String} {
            let answer: {UInt64: String} = {}
            for id in self.events.keys {
                let ref = (&self.events[id] as &FLOATEvent?)!
                answer[id] = ref.name
            }
            return answer
        }

        pub fun borrowViewResolver(id: UInt64): &{MetadataViews.Resolver} {
            return (&self.events[id] as &{MetadataViews.Resolver}?)!
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

    // A function to validate expected FLOAT metadata that must be in a 
    // certain format as to not cause aborts during expected casting
    pub fun validateExtraFloatMetadata(data: {String: AnyStruct}): Bool {
        if data.containsKey("medalType") {
            let medalType: String? = FLOAT.extraMetadataToStrOpt(data, "medalType")
            if medalType == nil || (medalType != "gold" && medalType != "silver" && medalType != "bronze" && medalType != "participation") {
                return false
            }
        }
        return true
    }

    // Helper to cast dictionary value to String? type
    //
    // Note about all the casting going on:
    // You might be saying, "Why are you double force unwrapping 
    // medalType Jacob?" "Why would an unwrapped type still needed to be unwrapped?" 
    // The reason is because in Cadence dictionaries, you can encounter double optionals
    // where the actual type that lies in the value of a dictionary is itself
    // nil. In other words, it's possible to have `{ "jacob": nil }` in a dictionary.
    // So we force unwrap due to the dictionary, then unwrap the value within.
    // It will never abort because we have checked for nil above, which checks 
    // for both types of nil.
    pub fun extraMetadataToStrOpt(_ dict: {String: AnyStruct}, _ key: String): String? {
        // `dict[key] == nil` means:
        //    1. the key doesn't exist
        //    2. the value for the key is nil
        if dict[key] == nil || dict[key]!!.getType() != Type<String>() {
            return nil
        }
        return dict[key]!! as! String
    }

    /// Function that returns all the Metadata Views implemented by a Non Fungible Token
    ///
    /// @return An array of Types defining the implemented views. This value will be used by
    ///         developers to know which parameter to pass to the resolveView() method.
    ///
    pub fun getViews(): [Type] {
        return [
            Type<MetadataViews.NFTCollectionData>(),
            Type<MetadataViews.NFTCollectionDisplay>()
        ]
    }

    /// Function that resolves a metadata view for this contract.
    ///
    /// @param view: The Type of the desired view.
    /// @return A structure representing the requested view.
    ///
    pub fun resolveView(_ view: Type): AnyStruct? {
        switch view {
            case Type<MetadataViews.NFTCollectionData>():
                return MetadataViews.NFTCollectionData(
                    storagePath: FLOAT.FLOATCollectionStoragePath,
                    publicPath: FLOAT.FLOATCollectionPublicPath,
                    providerPath: /private/FLOATCollectionPrivatePath,
                    publicCollection: Type<&Collection{CollectionPublic}>(),
                    publicLinkedType: Type<&Collection{CollectionPublic, NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, MetadataViews.ResolverCollection}>(),
                    providerLinkedType: Type<&Collection{CollectionPublic, NonFungibleToken.CollectionPublic, NonFungibleToken.Provider, MetadataViews.ResolverCollection}>(),
                    createEmptyCollectionFunction: (fun (): @NonFungibleToken.Collection {
                        return <- FLOAT.createEmptyCollection()
                    })
                )
            case Type<MetadataViews.NFTCollectionDisplay>():
                let squareMedia: MetadataViews.Media = MetadataViews.Media(
                    file: MetadataViews.HTTPFile(
                        url: "https://i.imgur.com/v0Njnnk.png"
                    ),
                    mediaType: "image"
                )
                let bannerMedia: MetadataViews.Media = MetadataViews.Media(
                    file: MetadataViews.HTTPFile(
                        url: "https://i.imgur.com/ETeVZZU.jpg"
                    ),
                    mediaType: "image"
                )
                return MetadataViews.NFTCollectionDisplay(
                    name: "FLOAT",
                    description: "FLOAT is a proof of attendance platform on the Flow blockchain.",
                    externalURL: MetadataViews.ExternalURL("https://floats.city"),
                    squareImage: squareMedia,
                    bannerImage: bannerMedia,
                    socials: {
                        "twitter": MetadataViews.ExternalURL("https://twitter.com/emerald_dao"),
                        "discord": MetadataViews.ExternalURL("https://discord.gg/emeraldcity")
                    }
                )
        }
        return nil
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

        // delete later

        if self.account.borrow<&FLOAT.Collection>(from: FLOAT.FLOATCollectionStoragePath) == nil {
            self.account.save(<- FLOAT.createEmptyCollection(), to: FLOAT.FLOATCollectionStoragePath)
            self.account.link<&FLOAT.Collection{NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection, FLOAT.CollectionPublic}>
                    (FLOAT.FLOATCollectionPublicPath, target: FLOAT.FLOATCollectionStoragePath)
        }

        if self.account.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath) == nil {
            self.account.save(<- FLOAT.createEmptyFLOATEventCollection(), to: FLOAT.FLOATEventsStoragePath)
            self.account.link<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic, MetadataViews.ResolverCollection}>
                        (FLOAT.FLOATEventsPublicPath, target: FLOAT.FLOATEventsStoragePath)
        }

        let FLOATEvents = self.account.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                        ?? panic("Could not borrow the FLOATEvents from the signer.")

        var verifiers: [{FLOAT.IVerifier}] = []

        let extraMetadata: {String: AnyStruct} = {}

        extraMetadata["backImage"] = "bafkreihwra72f2sby4h2bswej4zzrmparb6jy55ygjrymxjk572tjziatu"
        extraMetadata["eventType"] = "course"
        extraMetadata["certificateImage"] = "bafkreidcwg6jkcsugms2jtv6suwk2cao2ij6y57mopz4p4anpnvwswv2ku"

        FLOATEvents.createEvent(claimable: true, description: "Test description for the upcoming Flow Hackathon. This is soooo fun! Woohoo!", image: "bafybeifpsnwb2vkz4p6nxhgsbwgyslmlfd7jyicx5ukbj3tp7qsz7myzrq", name: "Flow Hackathon", transferrable: true, url: "", verifiers: verifiers, allowMultipleClaim: false, certificateType: "medal", visibilityMode: "certificate", extraMetadata: extraMetadata)
        
        extraMetadata["backImage"] = "bafkreihwra72f2sby4h2bswej4zzrmparb6jy55ygjrymxjk572tjziatu"
        extraMetadata["eventType"] = "discordMeeting"
        extraMetadata["certificateImage"] = "bafkreidcwg6jkcsugms2jtv6suwk2cao2ij6y57mopz4p4anpnvwswv2ku"

        FLOATEvents.createEvent(claimable: true, description: "Test description for a Discord meeting. This is soooo fun! Woohoo!", image: "bafybeifpsnwb2vkz4p6nxhgsbwgyslmlfd7jyicx5ukbj3tp7qsz7myzrq", name: "Discord Meeting", transferrable: true, url: "", verifiers: verifiers, allowMultipleClaim: false, certificateType: "ticket", visibilityMode: "picture", extraMetadata: extraMetadata)
    }
}
 