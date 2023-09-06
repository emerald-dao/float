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
        pub fun getEventMetadata(): &FLOATEvent{FLOATEventPublic}? {
            if let events = self.eventsCap.borrow() {
                return events.borrowPublicEventRef(eventId: self.eventId)
            }
            return nil
        }

        pub fun getExtraMetadata(): {String: AnyStruct} {
            if let event = self.getEventMetadata() {
                return event.getExtraFloatMetadata(serial: self.serial)
            }
            return {}
        }

        pub fun getImage(): String {
            if let extraEventMetadata: {String: AnyStruct} = self.getEventMetadata()?.getExtraMetadata() {
                if let certificateType: String = extraEventMetadata["certificateType"] as! String? {
                    if certificateType == "medal" {
                        // put extra metadata about colors
                        return (extraEventMetadata["certificateImage"] as! String?) ?? self.eventImage
                    }
                    return (extraEventMetadata["certificateImage"] as! String?) ?? self.eventImage
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
                Type<MetadataViews.Serial>(),
                Type<TokenIdentifier>()
            ]

            if self.getEventMetadata()?.transferrable == false {
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
                        thumbnail: MetadataViews.HTTPFile(url: "https://nftstorage.link/ipfs/".concat(self.getImage()))
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
                    let squareMedia = MetadataViews.Media(
                        file: MetadataViews.HTTPFile(
                           url: "https://i.imgur.com/uzt90wM.png"
                        ),
                        mediaType: "image"
                    )
                    let bannerMedia = MetadataViews.Media(
                        file: MetadataViews.HTTPFile(
                            url: "https://i.imgur.com/lEJuM70.png"
                        ),
                        mediaType: "image"
                    )
                    return MetadataViews.NFTCollectionDisplay(
                        name: "FLOAT",
                        description: "FLOAT is a proof of attendance platform on the Flow blockchain.",
                        externalURL: MetadataViews.ExternalURL("https://floats.city/".concat(self.eventHost.toString()).concat("/event/").concat(self.eventId.toString())),
                        squareImage: squareMedia,
                        bannerImage: bannerMedia,
                        socials: {
                            "twitter": MetadataViews.ExternalURL("https://twitter.com/emerald_dao"),
                            "discord": MetadataViews.ExternalURL("https://discord.gg/emeraldcity")
                        }
                    )
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
                    if self.getEventMetadata()?.transferrable == false {
                        return FindViews.SoulBound(
                            "This FLOAT is soulbound because the event host toggled off transferring."
                        )
                    }
                    return nil
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
            // If the FLOATEvent owner decided to unlink their public reference
            // for some reason (heavily recommend against it), their records
            // of who owns the FLOAT is going to be messed up. But that is their
            // fault. We shouldn't let that prevent the user from deleting the FLOAT.
            if let floatEvent: &FLOATEvent{FLOATEventPublic} = self.getEventMetadata() {
                floatEvent.updateFLOATHome(id: self.id, serial: self.serial, owner: nil)
            }
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
        access(account) var events: {UInt64: {UInt64: Bool}}

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

            // Try to update the FLOATEvent's current holders. This will
            // not work if they unlinked their FLOATEvent to the public,
            // and the data will go out of sync. But that is their fault.
            if let floatEvent: &FLOATEvent{FLOATEventPublic} = nft.getEventMetadata() {
                floatEvent.updateFLOATHome(id: id, serial: nft.serial, owner: self.owner!.address)
            }

            emit Deposit(id: id, to: self.owner!.address)
            self.ownedNFTs[id] <-! nft
        }

        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("You do not own this FLOAT in your collection")
            let nft <- token as! @NFT

            // Update self.events[eventId] to not
            // have this FLOAT's id in it
            self.events[nft.eventId]!.remove(key: withdrawID)

            // Try to update the FLOATEvent's current holders. This will
            // not work if they unlinked their FLOATEvent to the public,
            // and the data will go out of sync. But that is their fault.
            //
            // Additionally, this checks if the FLOATEvent host wanted this
            // FLOAT to be transferrable. Secondary marketplaces will use this
            // withdraw function, so if the FLOAT is not transferrable,
            // you can't sell it there.
            if let floatEvent: &FLOATEvent{FLOATEventPublic} = nft.getEventMetadata() {
                assert(
                    floatEvent.transferrable, 
                    message: "This FLOAT is not transferrable."
                )
                floatEvent.updateFLOATHome(id: withdrawID, serial: nft.serial, owner: nil)
            }

            emit Withdraw(id: withdrawID, from: self.owner!.address)
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
        pub fun getClaimed(): {Address: TokenIdentifier}
        pub fun getCurrentHolders(): {UInt64: TokenIdentifier}
        pub fun getCurrentHolder(serial: UInt64): TokenIdentifier?
        pub fun getExtraMetadata(): {String: AnyStruct}
        pub fun getVerifiers(): {String: [{IVerifier}]}
        pub fun getPrices(): {String: TokenInfo}?
        pub fun hasClaimed(account: Address): TokenIdentifier?
        pub fun getExtraFloatMetadata(serial: UInt64): {String: AnyStruct}

        access(account) fun updateFLOATHome(id: UInt64, serial: UInt64, owner: Address?)
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
        // DEPRECATED
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
        // from this event can be transferred on the
        // FLOAT platform itself (transferring allowed
        // elsewhere)
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

        /***************** Setters for the Contract Only *****************/

        // Called if a user moves their FLOAT to another location.
        // Needed so we can keep track of who currently has it.
        access(account) fun updateFLOATHome(id: UInt64, serial: UInt64, owner: Address?) {
            if owner == nil {
                self.currentHolders.remove(key: serial)
            } else {
                self.currentHolders[serial] = TokenIdentifier(
                    _id: id,
                    _address: owner!,
                    _serial: serial
                )
            }
            emit FLOATTransferred(id: id, eventHost: self.host, eventId: self.eventId, newOwner: owner, serial: serial)
        }

        access(self) fun setExtraFloatMetadata(serial: UInt64, metadata: {String: AnyStruct}) {
            if self.extraMetadata["extraFloatMetadatas"] == nil {
                let extraFloatMetadatas: {UInt64: AnyStruct} = {}
                self.extraMetadata["extraFloatMetadatas"] = extraFloatMetadatas
            }
            let e = (&self.extraMetadata["extraFloatMetadatas"] as auth &AnyStruct?)!
            let extraFloatMetadatas = e as! &{UInt64: AnyStruct}
            extraFloatMetadatas[serial] = metadata
        }

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

        /***************** Getters (all exposed to the public) *****************/

        pub fun getExtraFloatMetadata(serial: UInt64): {String: AnyStruct} {
            if let e = self.extraMetadata["extraFloatMetadatas"] as! {UInt64: AnyStruct}? {
                return e[serial] as! {String: AnyStruct}
            }
            return {}
        }

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

        pub fun getViews(): [Type] {
             return [
                Type<MetadataViews.Display>()
            ]
        }

        pub fun getPrices(): {String: TokenInfo}? {
            if let prices = self.extraMetadata["prices"] {
                return prices as! {String: TokenInfo}
            }
            return nil
        }

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

        access(account) fun verifyAndMint(recipient: &Collection, params: {String: AnyStruct}): UInt64 {
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
                self.claimed[recipient.owner!.address] == nil:
                    "This person already claimed their FLOAT!"
                self.claimable: 
                    "This FLOATEvent is not claimable, and thus not currently active."
            }
            
            self.verifyAndMint(recipient: recipient, params: params)
        }
 
        pub fun purchase(recipient: &Collection, params: {String: AnyStruct}, payment: @FungibleToken.Vault) {
            pre {
                self.getPrices() != nil:
                    "Don't call this function. The FLOAT is free."
                self.getPrices()![payment.getType().identifier] != nil:
                    "This FLOAT does not support purchasing in the passed in token."
                payment.balance == self.getPrices()![payment.getType().identifier]!.price:
                    "You did not pass in the correct amount of tokens."
                self.claimed[recipient.owner!.address] == nil:
                    "This person already claimed their FLOAT!"
                self.claimable: 
                    "This FLOATEvent is not claimable, and thus not currently active."
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
    }

    // A "Collection" of FLOAT Events
    pub resource FLOATEvents: FLOATEventsPublic, MetadataViews.ResolverCollection {
        // All the FLOAT Events this collection stores
        access(account) var events: @{UInt64: FLOATEvent}
        // DEPRECATED
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
            _ extraMetadata: {String: AnyStruct}
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

        /************* Getters (for anyone) *************/

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
        extraMetadata["certificateType"] = "certificate"
        extraMetadata["certificateImage"] = "bafkreidcwg6jkcsugms2jtv6suwk2cao2ij6y57mopz4p4anpnvwswv2ku"

        FLOATEvents.createEvent(claimable: true, description: "Test description for the upcoming Flow Hackathon. This is soooo fun! Woohoo!", image: "bafybeifpsnwb2vkz4p6nxhgsbwgyslmlfd7jyicx5ukbj3tp7qsz7myzrq", name: "Flow Hackathon", transferrable: true, url: "", verifiers: verifiers, extraMetadata)
        
        extraMetadata["backImage"] = "bafkreihwra72f2sby4h2bswej4zzrmparb6jy55ygjrymxjk572tjziatu"
        extraMetadata["eventType"] = "discordMeeting"
        extraMetadata["certificateType"] = "ticket"
        extraMetadata["certificateImage"] = "bafkreidcwg6jkcsugms2jtv6suwk2cao2ij6y57mopz4p4anpnvwswv2ku"

        FLOATEvents.createEvent(claimable: true, description: "Test description for a Discord meeting. This is soooo fun! Woohoo!", image: "bafybeifpsnwb2vkz4p6nxhgsbwgyslmlfd7jyicx5ukbj3tp7qsz7myzrq", name: "Discord Meeting", transferrable: true, url: "", verifiers: verifiers, extraMetadata)
    }
}
 