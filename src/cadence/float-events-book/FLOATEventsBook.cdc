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
    
    pub event ContractInitialized()
    pub event ContractTokenDefintionUpdated(identifier: String, path: PublicPath, isNFT: Bool)

    pub event FLOATEventsBookCreated(bookId: UInt64, host: Address, name: String, description: String, image: String)
    pub event FLOATEventsBookRevoked(bookId: UInt64, host: Address)
    pub event FLOATEventsBookBasicsUpdated(bookId: UInt64, host: Address, name: String, description: String, image: String)
    pub event FLOATEventsBookSlotUpdated(bookId: UInt64, host: Address, index: Int, eventHost: Address, eventId: UInt64)
    pub event FLOATEventsBookGoalAdded(bookId: UInt64, host: Address, goalTitle: String, points: UInt64)

    pub event FLOATEventsBookTreasuryTokenDeposit(bookId: UInt64, host: Address, identifier: String, amount: UFix64)
    pub event FLOATEventsBookTreasuryNFTDeposit(bookId: UInt64, host: Address, identifier: String, ids: [UInt64])
    pub event FLOATEventsBookTreasuryUpdateDropReceiver(bookId: UInt64, host: Address, receiver: Address)
    pub event FLOATEventsBookTreasuryStrategyAdded(bookId: UInt64, host: Address, strategyIdentifier: String)

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
        emit ContractTokenDefintionUpdated(identifier: tokenType, path: path, isNFT: isNFT)
    }

    access(account) fun getTokenDefintion(_ tokenIdentifier: String): TokenDefinition? {
        return self.tokenDefinitions[tokenIdentifier]
    }

    // a helper to get token recipient
    pub struct TokenRecipient {
        pub let address: Address
        pub let identifier: String

        init(address: Address, identifier: String) {
            self.address = address
            self.identifier = identifier
        }

        // check if the token is NFT
        access(contract) fun isNFT(): Bool {
            let tokenInfo = FLOATEventsBook.getTokenDefintion(self.identifier) ?? panic("Unknown token")
            return tokenInfo.isNFT
        }

        // get ft receiver by address and identifier
        access(contract) fun getFungibleTokenReceiver(): &{FungibleToken.Receiver} {
            let tokenInfo = FLOATEventsBook.getTokenDefintion(self.identifier) ?? panic("Unknown token")
            assert(!tokenInfo.isNFT, message: "The token should be Fungiable Token")

            let receiverVault = getAccount(self.address)
                .getCapability(tokenInfo.path)
                .borrow<&{FungibleToken.Receiver}>()
                ?? panic("Could not borrow the &{FungibleToken.Receiver} from ".concat(self.address.toString()))

            assert(
                receiverVault.getType().identifier == tokenInfo.type,
                message: "The receiver's path is not associated with the intended token."
            )
            return receiverVault
        }

        // get nft collection by address and identifier
        access(contract) fun getNFTCollectionPublic(): &{NonFungibleToken.CollectionPublic} {
            let tokenInfo = FLOATEventsBook.getTokenDefintion(self.identifier) ?? panic("Unknown token")
            assert(tokenInfo.isNFT, message: "The token should be Non-Fungiable Token")

            let collection = getAccount(self.address)
                .getCapability(tokenInfo.path)
                .borrow<&{NonFungibleToken.CollectionPublic}>()
                ?? panic("Could not borrow the &{NonFungibleToken.CollectionPublic} from ".concat(self.address.toString()))
            
            assert(
                collection.getType().identifier == tokenInfo.type,
                message: "The collection's path is not associated with the nft."
            )
            return collection
        }
    }

    // ---- data For Curators ----
    
    // identifier of an Event
    pub struct EventIdentifier {
        // event owner address
        pub let host: Address
        // event id
        pub let id: UInt64

        init(_ address: Address, _ id: UInt64) {
            self.host = address
            self.id = id
        }

        // get the reference of the given event
        pub fun getEventPublic(): &FLOAT.FLOATEvent{FLOAT.FLOATEventPublic}? {
            let ownerEvents = getAccount(self.host)
                .getCapability(FLOAT.FLOATEventsPublicPath)
                .borrow<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic}>()
                ?? panic("Could not borrow the public FLOATEvents.")
            return ownerEvents.borrowPublicEventRef(eventId: self.id)
        }
    }

    // identifier of a EventsBook
    pub struct EventsBookIdentifier {
        // book owner address
        pub let host: Address
        // book id
        pub let id: UInt64

        init(_ address: Address, _ id: UInt64) {
            self.host = address
            self.id = id
        }

        // get the reference of the given book
        pub fun getEventsBookPublic(): &{EventsBookPublic}? {
            let ref = getAccount(self.host)
                .getCapability(FLOATEventsBook.FLOATEventsBookshelfPublicPath)
                .borrow<&EventsBookshelf{EventsBookshelfPublic}>()
                ?? panic("Could not borrow the public EventsBookshelfPublic.")
            return ref.borrowEventsBook(bookId: self.id)
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

    // Achievement public interface
    pub resource interface AchievementPublic {
        // get total score
        pub fun getTotalScore(): UInt64
        // get current comsumable score
        pub fun getConsumableScore(): UInt64
        // get all finished goals
        pub fun getFinishedGoals(): [&{IAchievementGoal}]
        // point to the events book
        pub fun getTargetEventsBook(): &{EventsBookPublic}

        // Update treasury claimed information
        access(contract) fun treasuryClaimed(strategy: &{ITreasuryStrategy}) // ToCall
    }

    // Achievement private interface
    pub resource interface AchievementWritable {
        // current achievement score
        access(account) var score: UInt64
        // current consumable achievement score
        access(account) var consumableScore: UInt64
        // Achieve the goal and add to score
        access(account) fun accomplishGoal(goal: &{IAchievementGoal}) // ToCall
    }

    // An interface that every "achievement goal" must implement
    pub struct interface IAchievementGoal {
        // achievement title
        pub let title: String

        // how many points will be obtain when reach this goal
        pub fun getPoints(): UInt64
        // Will have `assert`s in it to make sure
        // the user fits some criteria.
        access(account) fun verify(_ eventsBook: &{EventsBookPublic}, user: Address) // ToCall
    }

    // Declare an enum to describe status
    pub enum StrategyState: UInt8 {
        pub case preparing
        pub case opening
        pub case claimable
        pub case closed
    }

    pub struct StrategyInformation {
        // minimium threshold of achievement score
        pub let threshold: UInt64
        // how many claimable shares
        pub let maxClaimableAmount: UInt64
        // how much FTs to claim for one share
        pub let oneShareOfClaimableFT: {String: Fix64}
        // how much NFTs to claim for one share
        pub let oneShareOfClaimableNFT: {String: UInt64}

        // current strategy stage
        pub var currentState: StrategyState
        // how many shares claimed
        pub var claimedAmount: UInt64

        init(
            _ threshold: UInt64,
            _ maxClaimableAmount: UInt64,
            _ oneShareOfClaimableFT: {String: Fix64},
            _ oneShareOfClaimableNFT: {String: UInt64}
        ) {
            pre {
                threshold > 0: "Threshold must be bigger than zero"
                maxClaimableAmount > 0: "claimable amount must be bigger than zero"
                oneShareOfClaimableFT.keys.length > 0 || oneShareOfClaimableNFT.keys.length > 0
                    : "at least one share of FT or NFTs to claim"
            }
            self.threshold = threshold
            self.maxClaimableAmount = maxClaimableAmount
            self.oneShareOfClaimableFT = oneShareOfClaimableFT
            self.oneShareOfClaimableNFT = oneShareOfClaimableNFT
            // variable
            self.currentState = StrategyState.preparing
            self.claimedAmount = 0
        }

        access(contract) fun setCurrentState(value: StrategyState) {
            self.currentState = value
        }

        access(contract) fun setClaimedAmount(value: UInt64) {
            self.claimedAmount = value
        }
    }

    // the general strategy controller
    pub resource StrategyController {
        access(self) let info: StrategyInformation

        init(
            threshold: UInt64,
            maxClaimableAmount: UInt64,
            oneShareOfClaimableFT: {String: Fix64},
            oneShareOfClaimableNFT: {String: UInt64}
        ) {
            self.info = StrategyInformation(threshold, maxClaimableAmount, oneShareOfClaimableFT, oneShareOfClaimableNFT)
        }

        // get strategy information
        access(contract) fun getInfo(): StrategyInformation {
            return self.info
        }

        // execute and go next
        access(contract) fun nextStage(): StrategyState { // ToCall
            pre {
                self.info.currentState != StrategyState.closed: "Strategy is closed"
            }
            self.info.setCurrentState(value: StrategyState(rawValue: self.info.currentState.rawValue + 1)!)
            return self.info.currentState
        }

        // claim one share
        access(contract) fun claimOneShare() { // ToCall
            pre {
                self.info.currentState == StrategyState.claimable: "Strategy should be claimable"
                self.info.claimedAmount < self.info.maxClaimableAmount: "Reach max claimable"
            }
            self.info.setClaimedAmount(value: self.info.claimedAmount + 1)
        }
    }

    // An interface that every "strategy" must implement.
    pub resource interface ITreasuryStrategy {
        // when claimed, if score will be consumed
        pub let consumable: Bool
        // strategy general controler
        access(account) let controller: @StrategyController

        init(
            controller: @StrategyController,
            consumable: Bool,
        ) {
            post {
                self.controller.getInfo().currentState == StrategyState.preparing: "CurrentState should be preparing"
                self.consumable == consumable: "Consumable must be initialized to the initial value"
            }
        }

        // check if strategy can go to claimable
        pub fun checkReadyToClaimable(): Bool {
            pre {
                self.controller.getInfo().currentState == StrategyState.opening: "Ensure current stage is opening."
            }
        }

        // update user's achievement
        access(account) fun updateAchievement(user: Capability<&{AchievementPublic}>) { // ToCall
            pre {
                self.controller.getInfo().currentState == StrategyState.opening: "Ensure current stage is opening."
            }
        }

        // verify if the user match the strategy
        pub fun verifyClaimable(user: Capability<&{AchievementPublic}>): Bool { // ToCall
            pre {
                self.controller.getInfo().currentState == StrategyState.claimable: "Ensure current stage is claimable."
            }
        }
    }

    // Treasury public interface
    pub resource interface TreasuryPublic {
        // get token balance from the token identifier
        pub fun getTreasuryTokenBalance(tokenIdentifier: String): &{FungibleToken.Balance}?
        // get nft collection public 
        pub fun getTreasuryNFTCollection(tokenIdentifier: String): &{NonFungibleToken.CollectionPublic}?
        // get all strategy information
        pub fun getStrategies(): [StrategyInformation]
        // For the public to claim rewards
        pub fun claim(strategyIndex: Int, recipients: [TokenRecipient])
    }

    // Treasury private interface
    pub resource interface TreasuryPrivate {
        // deposit ft to treasury
        pub fun depositFungibleToken(from: @FungibleToken.Vault)
        // deposit nft to treasury
        pub fun depositNFTs(collection: @NonFungibleToken.Collection)
        // add new strategy to the treasury
        pub fun addStrategy(strategy: @{ITreasuryStrategy}, autoStart: Bool)
    }

    // Treasury resource of each EventsBook (Optional)
    pub resource Treasury: TreasuryPublic, TreasuryPrivate {
        // Treasury bookID
        access(self) let bookId: UInt64
        // generic tokens will be dropped to this address, when treasury destory
        access(self) var receiver: Address

        // fungible token pool {identifier: Vault}
        access(self) var genericFTPool: @{String: FungibleToken.Vault}
        // non-fungible token pool {identifier: Collection}
        access(self) var genericNFTPool: @{String: NonFungibleToken.Collection}
        // all treasury strategies
        access(self) var strategies: @[{ITreasuryStrategy}]

        init(
            bookId: UInt64,
            dropReceiver: Address
        ) {
            self.bookId = bookId
            self.receiver = dropReceiver

            self.genericFTPool <- {}
            self.genericNFTPool <- {}

            self.strategies <- []
        }

        destroy() {
            // FT will be withdrawed to owner
            for identifier in self.genericFTPool.keys {
                let recipient = TokenRecipient(address: self.receiver, identifier: identifier)
                let receiverReciever = recipient.getFungibleTokenReceiver()
                receiverReciever.deposit(from: <- self.genericFTPool.remove(key: identifier)!)
            }
            destroy self.genericFTPool

            // NFT Token will be withdraw to owner
            for identifier in self.genericNFTPool.keys {
                let recipient = TokenRecipient(address: self.receiver, identifier: identifier)
                let receiverCollection = recipient.getNFTCollectionPublic()
                let collection = &self.genericNFTPool[identifier] as &{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}
                let keys = collection.getIDs()
                for id in keys {
                    receiverCollection.deposit(token: <- collection.withdraw(withdrawID: id))
                }
            }
            destroy self.genericNFTPool

            // destroy strategies
            destroy self.strategies
        }

        // --- Getters - Public Interfaces ---

        pub fun getTreasuryTokenBalance(tokenIdentifier: String): &{FungibleToken.Balance}? {
            return &self.genericFTPool[tokenIdentifier] as? &{FungibleToken.Balance}
        }

        pub fun getTreasuryNFTCollection(tokenIdentifier: String): &{NonFungibleToken.CollectionPublic}? {
            return &self.genericNFTPool[tokenIdentifier] as? &{NonFungibleToken.CollectionPublic}
        }

        // get all strategy information
        pub fun getStrategies(): [StrategyInformation] {
            let infos: [StrategyInformation] = []
            let len = self.strategies.length
            var i = 0
            while i < len {
                let strategyRef = &self.strategies[i] as &{ITreasuryStrategy}
                infos.append(strategyRef.controller.getInfo())
                i = i + 1
            }
            return infos
        }

        // execute claiming
        pub fun claim(
            strategyIndex: Int,
            recipients: [TokenRecipient],
        ) {
            // pre {
            //     self.currentState == StrategyState.claimable: "Ensure current stage is claimable."
            // }
            // TODO
        }

        // --- Setters - Private Interfaces ---

        // update DropReceiver
        pub fun updateDropReceiver(receiver: Address) {
            self.receiver = receiver

            emit FLOATEventsBookTreasuryUpdateDropReceiver(
                bookId: self.bookId,
                host: self.owner!.address,
                receiver: receiver
            )
        }

        // deposit ft to treasury
        pub fun depositFungibleToken(from: @FungibleToken.Vault) {
            let fromIdentifier = from.getType().identifier
            let tokenInfo = FLOATEventsBook.getTokenDefintion(fromIdentifier)
                ?? panic("This token is not defined.")
            assert(!tokenInfo.isNFT, message: "This token should be FT.")
            assert(fromIdentifier == tokenInfo.type, message: "From identifier should be same as definition")

            let amount = from.balance
            var vaultRef = &self.genericFTPool[tokenInfo.type] as? &{FungibleToken.Receiver}
            if vaultRef == nil  {
                self.genericFTPool[tokenInfo.type] <-! from
            } else {
                vaultRef.deposit(from: <- from)
            }

            emit FLOATEventsBookTreasuryTokenDeposit(
                bookId: self.bookId,
                host: self.owner!.address,
                identifier: fromIdentifier,
                amount: amount
            )
        }

        // deposit nft to treasury
        pub fun depositNFTs(collection: @NonFungibleToken.Collection) {
            let keys = collection.getIDs()
            assert(keys.length > 0, message: "Empty collection.")

            let nftIdentifier = collection.borrowNFT(id: keys[0]).getType().identifier
            let tokenInfo = FLOATEventsBook.getTokenDefintion(nftIdentifier)
                ?? panic("This token is not defined.")
            assert(tokenInfo.isNFT, message: "This token should be NFT.")
            assert(nftIdentifier == tokenInfo.type, message: "From identifier should be same as definition")

            let ids: [UInt64] = []
            var collectionRef = &self.genericNFTPool[nftIdentifier] as? &{NonFungibleToken.CollectionPublic}
            if collectionRef == nil {
                self.genericNFTPool[nftIdentifier] <-! collection
            } else {
                for id in keys {
                    ids.append(id)
                    collectionRef.deposit(token: <- collection.withdraw(withdrawID: id))
                }
                // delete empty collection
                destroy collection
            }

            emit FLOATEventsBookTreasuryNFTDeposit(
                bookId: self.bookId,
                host: self.owner!.address,
                identifier: nftIdentifier,
                ids: ids
            )
        }

        // add a new strategy
        pub fun addStrategy(strategy: @{ITreasuryStrategy}, autoStart: Bool) {
            // if autoStart is true and preparing, go next stage
            if autoStart && strategy.controller.getInfo().currentState == StrategyState.preparing {
                strategy.controller.nextStage()
            }

            let id = strategy.getType().identifier
            self.strategies.append(<- strategy)

            emit FLOATEventsBookTreasuryStrategyAdded(
                bookId: self.bookId,
                host: self.owner!.address,
                strategyIdentifier: id
            )
        }

        // --- Setters - Contract Only ---

        // --- Self Only ---

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
        // get last slot index
        pub fun getLastSlotIdx(): Int
        // get all slots data
        pub fun getSlots(): [{EventSlot}]
        // get all goals data
        pub fun getGoals(): [{IAchievementGoal}]
        // get treasury public
        pub fun getTreasury(): &Treasury{TreasuryPublic}
    }

    // A private interface to write for EventsBook
    pub resource interface EventsBookPrivate {
        // update basic information
        pub fun updateBasics(name: String, description: String, image: String)
        // update slot identifier information
        pub fun updateSlotData(idx: Int, identifier: EventIdentifier)
        // add a new achievement goal to the events book
        pub fun addAchievementGoal(goal: {IAchievementGoal})
    }

    // The events book defination
    pub resource EventsBook: EventsBookPublic, EventsBookPrivate, MetadataViews.Resolver {
        pub let sequence: UInt64
        pub let host: Address
        // --- basics ---
        pub var name: String
        pub var description: String
        pub var image: String

        access(account) var extra: {String: AnyStruct}
        // --- data ---
        // FLOAT slots
        access(account) let slots: [{EventSlot}]
        // Achievement goals
        access(account) let goals: [{IAchievementGoal}]
        // nest resource for the EventsBook treasury
        access(account) var treasury: @Treasury

        init(
            host: Address,
            name: String,
            description: String,
            image: String,
            slots: [{EventSlot}],
            goals: [{IAchievementGoal}],
            _ extra: {String: AnyStruct}
        ) {
            self.sequence = FLOATEventsBook.totalEventsBooks
            self.host = host

            self.name = name
            self.description = description
            self.image = image

            self.goals = goals
            self.slots = slots
            self.treasury <- create Treasury(
                bookId: self.uuid,
                dropReceiver: host
            )
            self.extra = extra

            FLOATEventsBook.totalEventsBooks = FLOATEventsBook.totalEventsBooks + 1
        }

        destroy() {
            destroy self.treasury
        }

        // --- Getters - Public Interfaces ---

        pub fun getViews(): [Type] {
            return [
                Type<MetadataViews.Display>(),
                Type<EventsBookIdentifier>()
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
                case Type<EventsBookIdentifier>():
                    return EventsBookIdentifier(self.owner!.address, self.uuid)
            }
            return nil
        }

        pub fun getID(): UInt64 {
            return self.uuid
        }

        pub fun getLastSlotIdx(): Int {
            return self.slots.length
        }

        pub fun getSlots(): [{EventSlot}] {
            return self.slots
        }

        pub fun getGoals(): [{IAchievementGoal}] {
            return self.goals
        }

        pub fun getTreasury(): &Treasury{TreasuryPublic} {
            return &self.treasury as &Treasury{TreasuryPublic}
        }

        // --- Setters - Private Interfaces ---

        pub fun updateBasics(name: String, description: String, image: String) {
            self.name = name
            self.description = description
            self.image = image

            emit FLOATEventsBookBasicsUpdated(
                bookId: self.uuid,
                host: self.host,
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
                host: self.host,
                index: idx,
                eventHost: identifier.host,
                eventId: identifier.id
            )
        }

        pub fun addAchievementGoal(goal: {IAchievementGoal}) {
            self.goals.append(goal)

            emit FLOATEventsBookGoalAdded(
                bookId: self.uuid,
                host: self.host,
                goalTitle: goal.title,
                points: goal.getPoints()
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
        // internal full reference borrowing
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
            slots: [{EventSlot}],
            goals: [{IAchievementGoal}],
            extra: {String: AnyStruct}
        ): UInt64
        // revoke a events book.
        pub fun revokeEventsBook(bookId: UInt64)
        // registor a token info for general usage
        pub fun registerToken(path: PublicPath, isNFT: Bool)
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
            slots: [{EventSlot}],
            goals: [{IAchievementGoal}],
            extra: {String: AnyStruct}
        ): UInt64 {
            let host = self.owner!.address

            let eventsBook <- create EventsBook(
                host: host,
                name: name,
                description: description,
                image: image,
                slots: slots,
                goals: goals,
                extra
            )
            let bookId = eventsBook.uuid
            self.books[bookId] <-! eventsBook

            emit FLOATEventsBookCreated(
                bookId: bookId,
                host: host,
                name: name,
                description: description,
                image: image
            )

            return bookId
        }

        pub fun revokeEventsBook(bookId: UInt64) {
            let book <- self.books.remove(key: bookId) ?? panic("The events book does not exist")
            self.revoked[bookId] <-! book
            
            emit FLOATEventsBookRevoked(bookId: bookId, host: self.owner!.address)
        }

        pub fun registerToken(path: PublicPath, isNFT: Bool) {
            // register token from owner's capability
            let tokenCap = self.owner!.getCapability(path)
            if isNFT {
                let nft = tokenCap.borrow<&{NonFungibleToken.CollectionPublic}>()
                    ?? panic("Could not borrow the &{NonFungibleToken.CollectionPublic}")
                FLOATEventsBook.setTokenDefintion(token: nft.getType(), path: path, isNFT: true)
            } else {
                let ft = tokenCap.borrow<&{FungibleToken.Receiver}>()
                    ?? panic("Could not borrow the &{FungibleToken.Receiver}")
                FLOATEventsBook.setTokenDefintion(token: ft.getType(), path: path, isNFT: false)
            }
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

    // Users' Achevement of one EventsBook
    pub resource Achievement {

    }

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
