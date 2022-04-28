// MADE BY: Bohao Tang

// This contract is for FLOAT Events Book

import NonFungibleToken from "../core-contracts/NonFungibleToken.cdc"
import MetadataViews from "../core-contracts/MetadataViews.cdc"
import FungibleToken from "../core-contracts/FungibleToken.cdc"
import FLOAT from "../float/FLOAT.cdc"

pub contract FLOATEventsBook {

    /**    ___  ____ ___ _  _ ____
       *   |__] |__|  |  |__| [__
        *  |    |  |  |  |  | ___]
         *************************/
    
    pub let FLOATEventsBookshelfStoragePath: StoragePath
    pub let FLOATEventsBookshelfPrivatePath: PrivatePath
    pub let FLOATEventsBookshelfPublicPath: PublicPath

    pub let FLOATAchievementsStoragePath: StoragePath
    pub let FLOATAchievementsPublicPath: PublicPath

    /**    ____ _  _ ____ _  _ ___ ____
       *   |___ |  | |___ |\ |  |  [__
        *  |___  \/  |___ | \|  |  ___]
         ******************************/
    
    // emitted when contract initialized
    pub event ContractInitialized()

    pub event FLOATEventsBookCreated(bookId: UInt64, name: String, description: String, image: String)
    pub event FLOATEventsBookRevoked(bookId: UInt64)
    pub event FLOATEventsBookBasicsUpdated(bookId: UInt64, name: String, description: String, image: String)
    pub event FLOATEventsBookSlotUpdated(bookId: UInt64, index: Int, eventCreator: Address, eventId: UInt64)

    pub event FLOATEventsBookshelfCreated(sequence: UInt64)

    /**    ____ ___ ____ ___ ____
       *   [__   |  |__|  |  |___
        *  ___]  |  |  |  |  |___
         ************************/
    
    // total events books amount
    pub var totalEventsBooks: UInt64
    // total events bookshelf amount
    pub var totalEventsBookshelf: UInt64

    // a registory of FT or NFT
    access(account) var tokenDefinitions: {String: TokenDefinition}

    /**    ____ _  _ _  _ ____ ___ _ ____ _  _ ____ _    _ ___ _   _
       *   |___ |  | |\ | |     |  | |  | |\ | |__| |    |  |   \_/
        *  |    |__| | \| |___  |  | |__| | \| |  | |___ |  |    |
         ***********************************************************/

    // the Token define struct of FT or NFT
    pub struct TokenDefinition {
        pub let type: String
        pub let path: PublicPath
        pub let isNFT: Bool

        init(type: String, path: PublicPath, isNFT: Bool) {
            self.type = type
            self.path = path
            self.isNFT = isNFT
        }
    }

    access(account) fun setTokenDefintion(token: Type, path: PublicPath, isNFT: Bool) {
        let tokenType = token.identifier
        self.tokenDefinitions[tokenType] = TokenDefinition(
            type: tokenType,
            path: path,
            isNFT: isNFT
        )
    }

    access(account) fun getTokenDefintion(_ tokenIdentifier: String): TokenDefinition? {
        return self.tokenDefinitions[tokenIdentifier]
    }

    // ---- data For Curators ----
    
    // identifier of an Event
    pub struct EventIdentifier {
        // event owner address
        pub let creator: Address
        // event id
        pub let id: UInt64

        init(_ address: Address, _ id: UInt64) {
            self.creator = address
            self.id = id
        }

        // get the reference of the given event
        pub fun getEventPublic(): &FLOAT.FLOATEvent{FLOAT.FLOATEventPublic}? {
            let ownerEvents = getAccount(self.creator)
                .getCapability(FLOAT.FLOATEventsPublicPath)
                .borrow<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic}>()
                ?? panic("Could not borrow the public FLOATEvents.")
            return ownerEvents.borrowPublicEventRef(eventId: self.id)
        }
    }

    // a readable interface of Event slot
    pub struct interface EventSlot {
        // get the event identifier
        pub fun getIdentifier(): EventIdentifier?
        // if the event is required for achievement
        pub fun isEventRequired(): Bool
    }

    // a writable interface of Event slot
    pub struct interface WritableEventSlot {
        // set the event identifier
        access(account) fun setIdentifier (_ identifier: EventIdentifier)
    }

    // set a required event slot of some specific event
    pub struct RequiredEventSlot: EventSlot {
        pub let identifier: EventIdentifier

        init(_ identifier: EventIdentifier) {
            self.identifier = identifier
        }

        pub fun getIdentifier(): EventIdentifier? {
            return self.identifier
        }

        pub fun isEventRequired(): Bool {
            return true
        }
    }
    
    // set an optional event slot of some specific event
    pub struct OptionalEventSlot: EventSlot, WritableEventSlot {
        pub var identifier: EventIdentifier?

        init(_ identifier: EventIdentifier?) {
            self.identifier = identifier
        }
        access(account) fun setIdentifier (_ identifier: EventIdentifier) {
            self.identifier = identifier
        }
        pub fun getIdentifier(): EventIdentifier? {
            return self.identifier
        }
        pub fun isEventRequired(): Bool {
            return false
        }
    }

    // set an event slot for unknown events
    pub struct EmptyEventSlot: EventSlot, WritableEventSlot {
        pub let isRequired: Bool
        pub var identifier: EventIdentifier?

        init(_ isRequired: Bool) {
            self.isRequired = isRequired
            self.identifier = nil
        }
        access(account) fun setIdentifier (_ identifier: EventIdentifier) {
            self.identifier = identifier
        }
        pub fun getIdentifier(): EventIdentifier? {
            return self.identifier
        }
        pub fun isEventRequired(): Bool {
            return self.isRequired
        }
    }

    // Treasury public interface
    pub resource interface TreasuryPublic {
        // get float collection
        pub fun getTreasuryFLOATCollection(): &{FLOAT.CollectionPublic}
        // get token balance from the token identifier
        pub fun getTreasuryTokenBalance(tokenIdentifier: String): &{FungibleToken.Balance}?
        // get nft collection public 
        pub fun getTreasuryNFTCollection(tokenIdentifier: String): &{NonFungibleToken.CollectionPublic}?
    }

    // Treasury resource of each EventsBook (Optional)
    pub resource Treasury: TreasuryPublic {
        // generic tokens will be dropped to this address, when treasury destory
        access(self) let receiver: Address

        // float collection of the treasury
        access(self) var floatCollection: @FLOAT.Collection
        // fungible token pool {identifier: Vault}
        access(self) var genericFTPool: @{String: FungibleToken.Vault}
        // non-fungible token pool {identifier: Collection}
        access(self) var genericNFTPool: @{String: NonFungibleToken.Collection}

        init(_ dropReceiver: Address) {
            self.receiver = dropReceiver

            self.floatCollection <- FLOAT.createEmptyCollection()
            self.genericFTPool <- {}
            self.genericNFTPool <- {}
        }

        destroy() {
            // directly destroy float collection
            destroy self.floatCollection

            // FT will be withdrawed to owner
            for identifier in self.genericFTPool.keys {
                let receiverReciever = self.getFungibleTokenReceiver(address: self.receiver, tokenIdentifier: identifier)
                receiverReciever.deposit(from: <- self.genericFTPool.remove(key: identifier)!)
            }
            destroy self.genericFTPool

            // NFT Token will be withdraw to owner
            for identifier in self.genericNFTPool.keys {
                let receiverCollection = self.getNFTCollectionPublic(address: self.receiver, tokenIdentifier: identifier)
                let collection = &self.genericNFTPool[identifier] as &{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}
                for id in collection.getIDs() {
                    receiverCollection.deposit(token: <- collection.withdraw(withdrawID: id))
                }
            }
            destroy self.genericNFTPool
        }

        // --- Getters - Public Interfaces ---

        pub fun getTreasuryFLOATCollection(): &{FLOAT.CollectionPublic} {
            return &self.floatCollection as &{FLOAT.CollectionPublic}
        }

        pub fun getTreasuryTokenBalance(tokenIdentifier: String): &{FungibleToken.Balance}? {
            return &self.genericFTPool[tokenIdentifier] as? &{FungibleToken.Balance}
        }

        pub fun getTreasuryNFTCollection(tokenIdentifier: String): &{NonFungibleToken.CollectionPublic}? {
            return &self.genericNFTPool[tokenIdentifier] as? &{NonFungibleToken.CollectionPublic}
        }

        // --- Setters - Private Interfaces ---

        // --- Setters - Contract Only ---

        // --- Self Only ---

        // get ft receiver by address and identifier
        access(self) fun getFungibleTokenReceiver(address: Address, tokenIdentifier: String): &{FungibleToken.Receiver} {
            let tokenInfo = FLOATEventsBook.getTokenDefintion(tokenIdentifier) ?? panic("Unknown token")
            assert(!tokenInfo.isNFT, message: "The token should be Fungiable Token")

            let receiverVault = getAccount(address)
                .getCapability(tokenInfo.path)
                .borrow<&{FungibleToken.Receiver}>()
                ?? panic("Could not borrow the &{FungibleToken.Receiver} from ".concat(address.toString()))

            assert(
                receiverVault.getType().identifier == tokenInfo.type,
                message: "The receiver's path is not associated with the intended token."
            )
            return receiverVault
        }

        // get nft collection by address and identifier
        access(self) fun getNFTCollectionPublic(address: Address, tokenIdentifier: String): &{NonFungibleToken.CollectionPublic} {
            let tokenInfo = FLOATEventsBook.getTokenDefintion(tokenIdentifier) ?? panic("Unknown token")
            assert(tokenInfo.isNFT, message: "The token should be Non-Fungiable Token")

            let collection = getAccount(address)
                .getCapability(tokenInfo.path)
                .borrow<&{NonFungibleToken.CollectionPublic}>()
                ?? panic("Could not borrow the &{NonFungibleToken.CollectionPublic} from ".concat(address.toString()))
            
            assert(
                collection.getType().identifier == tokenInfo.type,
                message: "The collection's path is not associated with the nft."
            )
            return collection
        }

    }

    // A public interface to read EventsBook
    pub resource interface EventsBookPublic {
        // ---- Members ----
        pub let sequence: UInt64
        // event basic display info
        pub var name: String
        pub var description: String
        pub var image: String

        // ---- Methods ----
        // get book id
        pub fun getID(): UInt64
        // get all slots data
        pub fun getSlots(): [{EventSlot}]
    }

    // A private interface to write for EventsBook
    pub resource interface EventsBookPrivate {
        // update basic information
        pub fun updateBasics(name: String, description: String, image: String)
        // update slot identifier information
        pub fun updateSlotData(idx: Int, identifier: EventIdentifier)
    }

    // The events book defination
    pub resource EventsBook: EventsBookPublic, EventsBookPrivate, MetadataViews.Resolver {
        pub let sequence: UInt64

        pub var name: String
        pub var description: String
        pub var image: String

        access(account) let slots: [{EventSlot}]
        access(account) let treasury: @Treasury?
        access(account) var extra: {String: AnyStruct}

        init(
            name: String,
            description: String,
            image: String,
            _ extra: {String: AnyStruct}
        ) {
            self.sequence = FLOATEventsBook.totalEventsBooks

            self.name = name
            self.description = description
            self.image = image

            self.slots = []
            self.treasury <- nil
            self.extra = extra

            emit FLOATEventsBookCreated(
                bookId: self.uuid,
                name: name,
                description: description,
                image: image
            )

            FLOATEventsBook.totalEventsBooks = FLOATEventsBook.totalEventsBooks + 1
        }

        destroy() {
            destroy self.treasury
        }

        // --- Getters - Public Interfaces ---

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
                        thumbnail: MetadataViews.IPFSFile(cid: self.image, path: nil)
                    )
            }
            return nil
        }

        pub fun getID(): UInt64 {
            return self.uuid
        }

        pub fun getSlots(): [{EventSlot}] {
            return self.slots
        }

        // --- Setters - Private Interfaces ---

        pub fun updateBasics(name: String, description: String, image: String) {
            self.name = name
            self.description = description
            self.image = image

            emit FLOATEventsBookBasicsUpdated(
                bookId: self.uuid,
                name: name,
                description: description,
                image: image
            )
        }

        pub fun updateSlotData(idx: Int, identifier: EventIdentifier) {
            pre {
                idx < self.slots.length: "The idx is out of Slots size."
            }
            let slot = self.slots[idx]
            assert(slot.isInstance(Type<OptionalEventSlot>()) || slot.isInstance(Type<EmptyEventSlot>()), message: "The slot should be writable")
            // update identifier information
            (slot as! &{WritableEventSlot}).setIdentifier(identifier)

            emit FLOATEventsBookSlotUpdated(
                bookId: self.uuid,
                index: idx,
                eventCreator: identifier.creator,
                eventId: identifier.id
            )
        }

        // --- Setters - Contract Only ---

        // --- Self Only ---

    }

    // A public interface to read EventsBookshelf
    pub resource interface EventsBookshelfPublic {
        // ---- Members ----
        pub let sequence: UInt64
        // ---- Methods ----
        pub fun isRevoked(bookId: UInt64): Bool
        pub fun borrowEventsBook(bookId: UInt64): &{EventsBookPublic}?

        access(account) fun borrowEventsBookFullRef(bookId: UInt64): &EventsBook?
        access(account) fun borrowEventsBookshelfFullRef(): &EventsBookshelf
    }

    // A private interface to write for EventsBookshelf
    pub resource interface EventsBookshelfPrivate {
        // create a new events book
        pub fun createEventsBook(
            name: String,
            description: String,
            image: String,
            extra: {String: AnyStruct}
        ): UInt64
        // revoke a events book.
        pub fun revokeEventsBook(bookId: UInt64)
    }

    // the events book resource collection
    pub resource EventsBookshelf: EventsBookshelfPublic, EventsBookshelfPrivate, MetadataViews.ResolverCollection {
        pub let sequence: UInt64

        access(account) var books: @{UInt64: EventsBook}
        access(account) var revoked: @{UInt64: EventsBook}

        init() {
            self.books <- {}
            self.revoked <- {}

            self.sequence = FLOATEventsBook.totalEventsBookshelf

            emit FLOATEventsBookshelfCreated(sequence: self.sequence)

            FLOATEventsBook.totalEventsBookshelf = FLOATEventsBook.totalEventsBookshelf + 1
        }

        destroy() {
            destroy self.books
            destroy self.revoked
        }

        // --- Getters - Public Interfaces ---
        
        pub fun getIDs(): [UInt64] {
            return self.books.keys
        }

        pub fun borrowViewResolver(id: UInt64): &{MetadataViews.Resolver} {
            return &self.books[id] as &{MetadataViews.Resolver}
        }

        pub fun borrowEventsBook(bookId: UInt64): &{EventsBookPublic}? {
            return &self.books[bookId] as? &EventsBook{EventsBookPublic}
        }

        pub fun isRevoked(bookId: UInt64): Bool {
            return self.revoked[bookId] != nil
        }
        
        // Maps the eventId to the name of that
        // events book. Just a kind helper.
        pub fun getAllEventsBooks(_ revoked: Bool): {UInt64: String} {
            let answer: {UInt64: String} = {}
            let keys = revoked ? self.revoked.keys : self.books.keys
            for id in keys {
                if revoked {
                    answer[id] = (&self.revoked[id] as &EventsBook).name
                } else {
                    answer[id] = (&self.books[id] as &EventsBook).name
                }
            }
            return answer
        }

        // --- Setters - Private Interfaces ---

        pub fun createEventsBook(
            name: String,
            description: String,
            image: String,
            extra: {String: AnyStruct}
        ): UInt64 {

            let eventsBook <- create EventsBook(
                name: name,
                description: description,
                image: image,
                extra
            )
            let bookId = eventsBook.uuid
            self.books[bookId] <-! eventsBook

            return bookId
        }

        pub fun revokeEventsBook(bookId: UInt64) {
            let book <- self.books.remove(key: bookId) ?? panic("The events book does not exist")
            self.revoked[bookId] <-! book
            
            emit FLOATEventsBookRevoked(bookId: bookId)
        }

        // --- Setters - Contract Only ---

        access(account) fun borrowEventsBookFullRef(bookId: UInt64): &EventsBook? {
            return &self.books[bookId] as? &EventsBook
        }

        access(account) fun borrowEventsBookshelfFullRef(): &EventsBookshelf {
            return &self as &EventsBookshelf
        }

        // --- Self Only ---

    }

    // ---- data For Endusers ----

    // Users' Achievement board
    pub resource AchievementBoard {

        init() {

        }

        // --- Getters - Public Interfaces ---

        // --- Setters - Private Interfaces ---

        // --- Setters - Contract Only ---

        // --- Self Only ---

    }

    // ---- contract methods ----

    pub fun createEventsBookshelf(): @EventsBookshelf {
        return <- create EventsBookshelf()
    }

    pub fun createAchievementBoard(): @AchievementBoard {
        return <- create AchievementBoard()
    }

    init() {
        self.totalEventsBooks = 0
        self.totalEventsBookshelf = 0
        self.tokenDefinitions = {}

        self.FLOATEventsBookshelfStoragePath = /storage/FLOATEventsBookshelfPath
        self.FLOATEventsBookshelfPrivatePath = /private/FLOATEventsBookshelfPath
        self.FLOATEventsBookshelfPublicPath = /public/FLOATEventsBookshelfPath

        self.FLOATAchievementsStoragePath = /storage/FLOATAchievementsPath
        self.FLOATAchievementsPublicPath = /public/FLOATAchievementsPath

        emit ContractInitialized()
    }
}
