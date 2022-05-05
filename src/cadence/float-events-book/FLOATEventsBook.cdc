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

    pub let FLOATAchievementBoardStoragePath: StoragePath
    pub let FLOATAchievementBoardPublicPath: PublicPath

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
    pub event FLOATEventsBookTreasuryStrategyAdded(bookId: UInt64, host: Address, strategyIdentifier: String, index: Int)
    pub event FLOATEventsBookTreasuryStrategyNextStage(bookId: UInt64, host: Address, strategyIdentifier: String, index: Int, stage: UInt8)
    pub event FLOATEventsBookTreasuryClaimed(bookId: UInt64, host: Address, strategyIdentifier: String, index: Int, claimer: Address)

    pub event FLOATEventsBookshelfCreated(sequence: UInt64)

    pub event FLOATAchievementRecordInitialized(bookId: UInt64, host: Address, owner: Address)
    pub event FLOATAchievementGoalAccomplished(bookId: UInt64, host: Address, owner: Address, goalIdx: Int)

    pub event FLOATAchievementBoardCreated(sequence: UInt64, owner: Address)

    /**    ____ ___ ____ ___ ____
       *   [__   |  |__|  |  |___
        *  ___]  |  |  |  |  |___
         ************************/
    
    // total events books amount
    pub var totalEventsBooks: UInt64
    // total events bookshelf amount
    pub var totalEventsBookshelfs: UInt64
    // total achievement board amount
    pub var totalAchievementBoards: UInt64

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

        init(_ address: Address, _ identifier: String) {
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
        pub fun getEventPublic(): &FLOAT.FLOATEvent{FLOAT.FLOATEventPublic} {
            let ownerEvents = getAccount(self.host)
                .getCapability(FLOAT.FLOATEventsPublicPath)
                .borrow<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic}>()
                ?? panic("Could not borrow the public FLOATEvents.")
            return ownerEvents.borrowPublicEventRef(eventId: self.id)
                ?? panic("Failed to get event reference.")
        }

        // convert identifier to string
        pub fun toString(): String {
            return self.host.toString().concat("#").concat(self.id.toString())
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
        pub fun getEventsBookPublic(): &{EventsBookPublic} {
            let ref = getAccount(self.host)
                .getCapability(FLOATEventsBook.FLOATEventsBookshelfPublicPath)
                .borrow<&EventsBookshelf{EventsBookshelfPublic}>()
                ?? panic("Could not borrow the public EventsBookshelfPublic.")
            return ref.borrowEventsBook(bookId: self.id)
                ?? panic("Failed to get events book reference.")
        }

        // convert identifier to string
        pub fun toString(): String {
            return self.host.toString().concat("#").concat(self.id.toString())
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

    // An interface that every "achievement goal" must implement
    pub struct interface IAchievementGoal {
        // achievement title
        pub let title: String

        // how many points will be obtain when reach this goal
        pub fun getPoints(): UInt64 {
            post {
                result > 0: "Point should be greater than zero."
            }
        }

        // Fetch detail of the goal
        pub fun getGoalDetail(): {String: AnyStruct}

        // Check if user fits some criteria.
        access(account) fun verify(_ eventsBook: &{EventsBookPublic}, user: Address): Bool
    }

    // Declare an enum to describe status
    pub enum StrategyState: UInt8 {
        pub case preparing
        pub case opening
        pub case claimable
        pub case closed
    }

    pub struct StrategyInformation {
        // when claimed, if score will be consumed
        pub let consumable: Bool
        // minimium threshold of achievement score
        pub let threshold: UInt64
        // how many claimable shares
        pub let maxClaimableAmount: UInt64
        // how much FTs to claim for one share
        pub let oneShareOfClaimableFT: {String: UFix64}
        // how much NFTs to claim for one share
        pub let oneShareOfClaimableNFT: {String: UInt64}

        // current strategy stage
        pub var currentState: StrategyState
        // how many shares claimed
        pub var claimedAmount: UInt64

        init(
            _ consumable: Bool,
            _ threshold: UInt64,
            _ maxClaimableAmount: UInt64,
            _ oneShareOfClaimableFT: {String: UFix64},
            _ oneShareOfClaimableNFT: {String: UInt64}
        ) {
            pre {
                threshold > 0: "Threshold must be bigger than zero"
                maxClaimableAmount > 0: "claimable amount must be bigger than zero"
                oneShareOfClaimableFT.keys.length > 0 || oneShareOfClaimableNFT.keys.length > 0
                    : "at least one share of FT or NFTs to claim"
            }
            self.consumable = consumable
            self.threshold = threshold
            self.maxClaimableAmount = maxClaimableAmount
            self.oneShareOfClaimableFT = oneShareOfClaimableFT
            self.oneShareOfClaimableNFT = oneShareOfClaimableNFT
            // variable
            self.currentState = StrategyState.preparing
            self.claimedAmount = 0
        }

        // set current state
        access(contract) fun setCurrentState(value: StrategyState) {
            self.currentState = value
        }

        // set current amount
        access(contract) fun setClaimedAmount(value: UInt64) {
            self.claimedAmount = value
        }

        // clone an object
        access(contract) fun clone(): StrategyInformation {
            let ret = StrategyInformation(
                self.consumable,
                self.threshold,
                self.maxClaimableAmount,
                self.oneShareOfClaimableFT,
                self.oneShareOfClaimableNFT
            )
            ret.currentState = self.currentState
            ret.claimedAmount = self.claimedAmount
            return ret
        }
    }

    // the general strategy controller
    pub resource StrategyController {
        // basic info
        access(self) let info: StrategyInformation
        access(self) let claimed: [Address]

        init(
            consumable: Bool,
            threshold: UInt64,
            maxClaimableAmount: UInt64,
            oneShareOfClaimableFT: {String: UFix64},
            oneShareOfClaimableNFT: {String: UInt64}
        ) {
            self.info = StrategyInformation(consumable, threshold, maxClaimableAmount, oneShareOfClaimableFT, oneShareOfClaimableNFT)
            self.claimed = []
        }

        // get a copy of strategy information
        pub fun getInfo(): StrategyInformation {
            return self.info.clone()
        }

        // get claimed addresses
        pub fun getClaimedAddresses(): [Address] {
            return self.claimed
        }

        // if user has claimed
        pub fun hasClaimed(address: Address): Bool {
            return self.claimed.contains(address)
        }

        // execute and go next
        access(contract) fun nextStage(): StrategyState {
            pre {
                self.info.currentState != StrategyState.closed: "Strategy is closed"
            }
            self.info.setCurrentState(value: StrategyState(rawValue: self.info.currentState.rawValue + 1)!)
            return self.info.currentState
        }

        // ---------- claimable Stage ----------

        // verify if user can claim this
        access(contract) fun verifyScore(user: &{AchievementPublic}): Bool {
            let thresholdScore = self.info.threshold
            if self.info.consumable {
                assert(thresholdScore <= user.getConsumableScore(), message: "Consumable score is not enough.")
            } else {
                assert(thresholdScore <= user.getTotalScore(), message: "Total score is not enough.")
            }
            return true
        }

        // verify if the state is claimable
        access(contract) fun verifyClaimableState(): Bool {
            pre {
                self.info.currentState == StrategyState.claimable: "Ensure current stage is claimable."
                self.info.claimedAmount < self.info.maxClaimableAmount: "Reach max claimable"
            }
            return true
        }

        // claim one share
        access(contract) fun oneShareClaimed(user: &{AchievementPublic}): UInt64 {
            pre {
                self.info.currentState == StrategyState.claimable: "Ensure current stage is claimable."
                self.info.claimedAmount < self.info.maxClaimableAmount: "Reach max claimable"
                !self.hasClaimed(address: user.getOwner()): "The user has claimed one share."
            }
            self.info.setClaimedAmount(value: self.info.claimedAmount + 1)
            self.claimed.append(user.getOwner())
            return self.info.claimedAmount
        }
    }

    // An interface that every "strategy" must implement.
    pub resource interface ITreasuryStrategy {
        // strategy general controler
        access(account) let controller: @StrategyController

        init(
            controller: @StrategyController,
            params: {String: AnyStruct}
        ) {
            post {
                self.controller.getInfo().currentState == StrategyState.preparing: "CurrentState should be preparing"
            }
        }

        // Fetch detail of the strategy
        pub fun getStrategyDetail(): AnyStruct

        // invoked when state changed
        access(account) fun onStateChanged(state: StrategyState)

        // ---------- opening Stage ----------

        // update user's achievement
        access(account) fun onGoalAccomplished(user: &{AchievementPublic}) {
            pre {
                self.controller.getInfo().currentState == StrategyState.opening: "Ensure current stage is opening."
            }
        }

        // ---------- claimable Stage ----------

        // verify if the user match the strategy
        access(account) fun verifyClaimable(user: &{AchievementPublic}): Bool {
            pre {
                self.controller.verifyScore(user: user): "The user cannot to claim for now"
                self.controller.verifyClaimableState(): "Verify if the strategy is claimable"
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
        pub fun getStrategies(state: StrategyState?): [StrategyInformation]
        // For the public to claim rewards
        pub fun claim(strategyIndex: Int, user: &{AchievementPublic})

        // borrow strategy reference
        access(contract) fun borrowStrategyRef(idx: Int): &{ITreasuryStrategy}
        // borrow strategies by state reference
        access(contract) fun borrowStrategiesRef(state: StrategyState?): [&{ITreasuryStrategy}]
    }

    // Treasury private interface
    pub resource interface TreasuryPrivate {
        // update drop receiver
        pub fun updateDropReceiver(receiver: Address)
        // deposit ft to treasury
        pub fun depositFungibleToken(from: @FungibleToken.Vault)
        // deposit nft to treasury
        pub fun depositNFTs(collection: @NonFungibleToken.Collection)
        // add new strategy to the treasury
        pub fun addStrategy(strategy: @{ITreasuryStrategy}, autoStart: Bool)
        // update strategy status
        pub fun nextStrategyStage(idx: Int): StrategyState
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
                let recipient = TokenRecipient(self.receiver, identifier)
                let receiverReciever = recipient.getFungibleTokenReceiver()
                receiverReciever.deposit(from: <- self.genericFTPool.remove(key: identifier)!)
            }
            destroy self.genericFTPool

            // NFT Token will be withdraw to owner
            for identifier in self.genericNFTPool.keys {
                let recipient = TokenRecipient(self.receiver, identifier)
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
        pub fun getStrategies(state: StrategyState?): [StrategyInformation] {
            let infos: [StrategyInformation] = []
            let len = self.strategies.length
            var i = 0
            while i < len {
                let strategyRef = &self.strategies[i] as &{ITreasuryStrategy}
                let info = strategyRef.controller.getInfo()
                if state == nil || state! == info.currentState {
                    infos.append(info)
                }
                i = i + 1
            }
            return infos
        }

        // execute claiming
        pub fun claim(
            strategyIndex: Int,
            user: &{AchievementPublic}
        ) {
            // ensure achievement record should be same
            let achievementIdentifier = user.getTarget().toString()
            let bookIdentifier = self.getParentIdentifier().toString()
            assert(achievementIdentifier == bookIdentifier, message: "Achievement identifier should be same as events book identifier")

            // verify if user can claim
            let strategy = self.borrowStrategyRef(idx: strategyIndex)
            assert(strategy.verifyClaimable(user: user), message: "Currently the user cannot to do claiming.")

            // distribute tokens
            let strategyInfo = strategy.controller.getInfo()
            let claimer = user.getOwner()

            // FT rewards
            let ftRewards = strategyInfo.oneShareOfClaimableFT
            for ftIdentifier in ftRewards.keys {
                let amount = ftRewards[ftIdentifier]!
                let recipient = TokenRecipient(claimer, ftIdentifier).getFungibleTokenReceiver()
                // transfer FT rewards
                self.verifyAndTransferFT(identifer: ftIdentifier, amount: amount, recipient: recipient)
            }

            // NFT rewards
            let nftRewards = strategyInfo.oneShareOfClaimableNFT
            for nftIdentifier in nftRewards.keys {
                let amount = nftRewards[nftIdentifier]!
                let recipient = TokenRecipient(claimer, nftIdentifier).getNFTCollectionPublic()
                // transfer NFT rewards
                self.verifyAndTransferNFT(identifer: nftIdentifier, amount: amount, recipient: recipient)
            }

            // execute claim one share
            let currentClaimed = strategy.controller.oneShareClaimed(user: user)

            // update achievement record
            user.treasuryClaimed(strategy: strategy)

            // emit claimed event
            emit FLOATEventsBookTreasuryClaimed(
                bookId: self.bookId,
                host: self.owner!.address,
                strategyIdentifier: strategy.getType().identifier,
                index: strategyIndex,
                claimer: user.getOwner()
            )

            // check if all shares claimed, go next stage
            if currentClaimed >= strategyInfo.maxClaimableAmount {
                self.nextStrategyStage(idx: strategyIndex)
            }
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

            let nftIdentifier = collection.getType().identifier
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
                strategyIdentifier: id,
                index: self.strategies.length - 1
            )
        }

        // go next strategy stage
        pub fun nextStrategyStage(idx: Int): StrategyState {
            let strategy = self.borrowStrategyRef(idx: idx)
            let currentState = strategy.controller.getInfo().currentState

            // go to next stage
            let ret = strategy.controller.nextStage()
            // execute on state changed
            strategy.onStateChanged(state: ret)

            emit FLOATEventsBookTreasuryStrategyNextStage(
                bookId: self.bookId,
                host: self.owner!.address,
                strategyIdentifier: strategy.getType().identifier,
                index: idx,
                stage: ret.rawValue
            )
            return ret
        }

        // --- Setters - Contract Only ---

        // borrow strategy reference
        access(contract) fun borrowStrategyRef(idx: Int): &{ITreasuryStrategy} {
            pre {
                idx >= 0 && idx < self.strategies.length: "Strategy does not exist."
            }
            return &self.strategies[idx] as &{ITreasuryStrategy}
        }

        // borrow strategies by state reference
        access(contract) fun borrowStrategiesRef(state: StrategyState?): [&{ITreasuryStrategy}] {
            let ret: [&{ITreasuryStrategy}] = []
            let len = self.strategies.length
            var i = 0
            while i < len {
                let strategyRef = &self.strategies[i] as &{ITreasuryStrategy}
                let info = strategyRef.controller.getInfo()
                if state == nil || state! == info.currentState {
                    ret.append(strategyRef)
                }
                i = i + 1
            }
            return ret
        }

        // --- Self Only ---

        // withdraw FT from treasury and transfer to recipient
        access(self) fun verifyAndTransferFT(identifer: String, amount: UFix64, recipient: &{FungibleToken.Receiver}) {
            let tokenInfo = FLOATEventsBook.getTokenDefintion(identifer)
                ?? panic("This token is not defined.")
            assert(!tokenInfo.isNFT, message: "This token should be FT.")

            // ensure type is same
            let recipientIdentifier = recipient.getType().identifier
            assert(recipientIdentifier == tokenInfo.type, message: "Recipient identifier should be same as definition")
            assert(self.genericFTPool[tokenInfo.type] != nil, message: "There is no ft in the treasury.")

            // ensure amount enough
            let treasuryRef = &self.genericFTPool[tokenInfo.type] as! &{FungibleToken.Provider, FungibleToken.Balance}
            assert(treasuryRef.balance >= amount, message: "The balance is not enough.")

            // do 'transfer' action
            recipient.deposit(from: <- treasuryRef.withdraw(amount: amount))
        }

        // withdraw NFT from treasury and transfer to recipient
        access(self) fun verifyAndTransferNFT(identifer: String, amount: UInt64, recipient: &{NonFungibleToken.CollectionPublic}) {
            let tokenInfo = FLOATEventsBook.getTokenDefintion(identifer)
                ?? panic("This token is not defined.")
            assert(tokenInfo.isNFT, message: "This token should be NFT.")

            // ensure type is same
            let recipientIdentifier = recipient.getType().identifier
            assert(recipientIdentifier == tokenInfo.type, message: "Recipient identifier should be same as definition")
            assert(self.genericNFTPool[tokenInfo.type] != nil, message: "There is no nft in the treasury.")

            // ensure amount enough
            let treasuryRef = &self.genericNFTPool[tokenInfo.type] as! &{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}
            let ids = treasuryRef.getIDs()
            assert(ids.length > 0 && UInt64(ids.length) >= amount, message: "NFTs is not enough.")

            // do 'batch transfer' action
            var i: UInt64 = 0
            while i < amount {
                recipient.deposit(token: <- treasuryRef.withdraw(withdrawID: ids.removeFirst()))
                i = i + 1
            }
        }

        // get identifier
        access(self) fun getParentIdentifier(): EventsBookIdentifier {
            return EventsBookIdentifier(self.owner!.address, self.bookId)
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
        // get book identifier
        pub fun getIdentifier(): EventsBookIdentifier
        // get last slot index
        pub fun getLastSlotIdx(): Int
        // get all slots data
        pub fun getSlots(): [{EventSlot}]
        // get a event slot by index
        pub fun getSlot(idx: Int): {EventSlot}
        // get all goals data
        pub fun getGoals(): [{IAchievementGoal}]
        // get an achievement goal by index
        pub fun getGoal(idx: Int): {IAchievementGoal}
        // borrow the treasury public reference
        pub fun borrowTreasury(): &Treasury{TreasuryPublic}
    }

    // A private interface to write for EventsBook
    pub resource interface EventsBookPrivate {
        // borrow the treasury private reference
        pub fun borrowTreasuryPrivate(): &Treasury{TreasuryPublic, TreasuryPrivate}
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
        access(contract) var treasury: @Treasury

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
                    return self.getIdentifier()
            }
            return nil
        }

        pub fun getID(): UInt64 {
            return self.uuid
        }
        
        pub fun getIdentifier(): EventsBookIdentifier {
            return EventsBookIdentifier(self.owner!.address, self.uuid)
        }

        pub fun getLastSlotIdx(): Int {
            return self.slots.length
        }

        pub fun getSlots(): [{EventSlot}] {
            return self.slots
        }

        pub fun getSlot(idx: Int): {EventSlot} {
            pre {
                idx >= 0 && idx < self.slots.length: "Slot does not exist."
            }
            return self.slots[idx]
        }

        pub fun getGoals(): [{IAchievementGoal}] {
            return self.goals
        }

        pub fun getGoal(idx: Int): {IAchievementGoal} {
            pre {
                idx >= 0 && idx < self.goals.length: "Goal does not exist."
            }
            return self.goals[idx]
        }

        pub fun borrowTreasury(): &Treasury{TreasuryPublic} {
            return &self.treasury as &Treasury{TreasuryPublic}
        }

        // --- Setters - Private Interfaces ---

        // borrow the treasury private reference
        pub fun borrowTreasuryPrivate(): &Treasury{TreasuryPublic, TreasuryPrivate} {
            return &self.treasury as &Treasury{TreasuryPublic, TreasuryPrivate}
        }

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

        // create strategy controller
        pub fun createStrategyController(
            consumable: Bool,
            threshold: UInt64,
            maxClaimableAmount: UInt64,
            oneShareOfClaimableFT: {String: UFix64},
            oneShareOfClaimableNFT: {String: UInt64},
        ): @StrategyController

        // borrow eventsbook private ref
        pub fun borrowEventsBookPrivate(bookId: UInt64): &EventsBook{EventsBookPrivate}?
    }

    // the events book resource collection
    pub resource EventsBookshelf: EventsBookshelfPublic, EventsBookshelfPrivate, MetadataViews.ResolverCollection {
        pub let sequence: UInt64

        access(account) var books: @{UInt64: EventsBook}
        access(account) var revoked: @{UInt64: EventsBook}

        init() {
            self.books <- {}
            self.revoked <- {}

            self.sequence = FLOATEventsBook.totalEventsBookshelfs

            emit FLOATEventsBookshelfCreated(sequence: self.sequence)

            FLOATEventsBook.totalEventsBookshelfs = FLOATEventsBook.totalEventsBookshelfs + 1
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

        // create the controller resource
        pub fun createStrategyController(
            consumable: Bool,
            threshold: UInt64,
            maxClaimableAmount: UInt64,
            oneShareOfClaimableFT: {String: UFix64},
            oneShareOfClaimableNFT: {String: UInt64},
        ): @StrategyController {
            return <- create StrategyController(
                consumable: consumable,
                threshold: threshold,
                maxClaimableAmount: maxClaimableAmount,
                oneShareOfClaimableFT: oneShareOfClaimableFT,
                oneShareOfClaimableNFT: oneShareOfClaimableNFT
            )
        }

        pub fun borrowEventsBookPrivate(bookId: UInt64): &EventsBook{EventsBookPublic, EventsBookPrivate}? {
            return &self.books[bookId] as? &EventsBook{EventsBookPublic, EventsBookPrivate}
        }

        // --- Setters - Contract Only ---

        access(account) fun borrowEventsBookshelfFullRef(): &EventsBookshelf {
            return &self as &EventsBookshelf
        }

        // --- Self Only ---

    }

    // ---- data For Endusers ----

    // Achievement public interface
    pub resource interface AchievementPublic {
        // get achievement record owner
        pub fun getOwner(): Address
        // get achievement record target
        pub fun getTarget(): EventsBookIdentifier
        // get total score
        pub fun getTotalScore(): UInt64
        // get current comsumable score
        pub fun getConsumableScore(): UInt64
        // get all finished goals
        pub fun getFinishedGoals(): [{IAchievementGoal}]
        // check if goal can be accomplished
        pub fun isGoalReached(goalIdx: Int): Bool

        // Update treasury claimed information
        access(contract) fun treasuryClaimed(strategy: &{ITreasuryStrategy})
    }

    // Achievement private interface
    pub resource interface AchievementWritable {
        // execute verify and accomplish 
        pub fun accomplishGoal(goalIdx: Int)
    }

    // Users' Achevement of one EventsBook
    pub resource Achievement: AchievementPublic, AchievementWritable {
        // target to event identifier
        access(self) let target: EventsBookIdentifier
        // current achievement score
        access(account) var score: UInt64
        // current consumable achievement score
        access(account) var consumableScore: UInt64
        // all finished goals 
        access(account) var finishedGoals: [Int]

        init(
            host: Address,
            bookId: UInt64
        ) {
            self.score = 0
            self.consumableScore = 0
            self.finishedGoals = []

            self.target = EventsBookIdentifier(host, bookId)
        }

        // --- Getters - Public Interfaces ---

        // get achievement record owner
        pub fun getOwner(): Address {
            return self.owner!.address
        }

        // get achievement record target
        pub fun getTarget(): EventsBookIdentifier {
            return self.target
        }

        // get total score
        pub fun getTotalScore(): UInt64 {
            return self.score
        }

        // get current comsumable score
        pub fun getConsumableScore(): UInt64 {
            return self.consumableScore
        }

        // get all finished goals
        pub fun getFinishedGoals(): [{IAchievementGoal}] {
            let eventsBookRef = self.getTarget().getEventsBookPublic()

            var ret: [{IAchievementGoal}] = []
            for idx in self.finishedGoals {
                ret.append(eventsBookRef.getGoal(idx: idx))
            }
            return ret
        }

        // check if goal can be accomplished
        pub fun isGoalReached(goalIdx: Int): Bool {
            // fetch the events book reference
            let eventsBookRef = self.getTarget().getEventsBookPublic()
            let goal = eventsBookRef.getGoal(idx: goalIdx)

            return goal.verify(eventsBookRef, user: self.owner!.address)
        }

        // --- Setters - Private Interfaces ---

        // Achieve the goal and add to score
        pub fun accomplishGoal(goalIdx: Int) {
            pre {
                !self.finishedGoals.contains(goalIdx): "The goal is already accomplished."
            }

            // fetch the events book reference
            let eventsBookRef = self.getTarget().getEventsBookPublic()
            let goal = eventsBookRef.getGoal(idx: goalIdx)

            // verify first. if not allowed, the method will panic
            assert(goal.verify(eventsBookRef, user: self.owner!.address), message: "Failed to verify goal")

            // add to score
            let point = goal.getPoints()
            self.score = self.score.saturatingAdd(point)
            self.consumableScore = self.consumableScore.saturatingAdd(point)

            // update achievement to all opening treasury strategies
            let treasury = eventsBookRef.borrowTreasury()
            let openingStrategies = treasury.borrowStrategiesRef(state: StrategyState.opening)
            for strategy in openingStrategies {
                strategy.onGoalAccomplished(user: &self as &{AchievementPublic})
            }

            // add to finished goal
            self.finishedGoals.append(goalIdx)

            // emit event
            emit FLOATAchievementGoalAccomplished(
                bookId: eventsBookRef.getID(),
                host: eventsBookRef.owner!.address,
                owner: self.owner!.address,
                goalIdx: goalIdx
            )
        }

        // --- Setters - Contract Only ---

        // Update treasury claimed information
        access(contract) fun treasuryClaimed(strategy: &{ITreasuryStrategy}) {
            let info = strategy.controller.getInfo()
            // only consumable strategy will update score
            if info.consumable {
                assert(self.consumableScore >= info.threshold, message: "Consumable score is not enough.")

                self.consumableScore = self.consumableScore.saturatingSubtract(info.threshold)
            }
        }

        // --- Self Only ---

    }

    // A public interface to read AchievementBoard
    pub resource interface AchievementBoardPublic {
        // get the achievement reference by events book identifier
        pub fun borrowAchievementRecordRef(host: Address, bookId: UInt64): &{AchievementPublic}?
    }

    // A private interface to write AchievementBoard
    pub resource interface AchievementBoardPrivate {
        // create achievement by host and id
        pub fun createAchievementRecord(host: Address, bookId: UInt64): EventsBookIdentifier
        // get the achievement record reference by events book identifier
        pub fun borrowAchievementRecordWritable(host: Address, bookId: UInt64): &{AchievementPublic, AchievementWritable}?
    }

    // Users' Achievement board
    pub resource AchievementBoard: AchievementBoardPublic, AchievementBoardPrivate {
        pub let sequence: UInt64
        // all achievement resources
        access(account) var achievements: @{String: Achievement}

        init() {
            self.sequence = FLOATEventsBook.totalAchievementBoards
            self.achievements <- {}

            emit FLOATAchievementBoardCreated(
                sequence: self.sequence,
                owner: self.owner!.address
            )

            FLOATEventsBook.totalAchievementBoards = FLOATEventsBook.totalAchievementBoards + 1
        }

        destroy() {
            destroy self.achievements
        }

        // --- Getters - Public Interfaces ---

        pub fun borrowAchievementRecordRef(host: Address, bookId: UInt64): &{AchievementPublic}? {
            let target = EventsBookIdentifier(host, bookId)
            let key = target.toString()
            return &self.achievements[key] as? &{AchievementPublic}
        }

        // --- Setters - Private Interfaces ---

        // create achievement by host and id
        pub fun createAchievementRecord(host: Address, bookId: UInt64): EventsBookIdentifier {
            let identifier = EventsBookIdentifier(host, bookId)
            let key = identifier.toString()

            assert(self.achievements[key] == nil, message: "Achievement of the event book should be empty.")
            assert(identifier.getEventsBookPublic() != nil , message: "The events book should exist")

            self.achievements[key] <-! create Achievement(
                host: host,
                bookId: bookId
            )

            emit FLOATAchievementRecordInitialized(
                bookId: bookId,
                host: host,
                owner: self.owner!.address
            )
            return identifier
        }

        pub fun borrowAchievementRecordWritable(host: Address, bookId: UInt64): &{AchievementPublic, AchievementWritable}? {
            let target = EventsBookIdentifier(host, bookId)
            let key = target.toString()
            return &self.achievements[key] as? &{AchievementPublic, AchievementWritable}
        }

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
        self.totalEventsBookshelfs = 0
        self.totalAchievementBoards = 0
        self.tokenDefinitions = {}

        self.FLOATEventsBookshelfStoragePath = /storage/FLOATEventsBookshelfPath
        self.FLOATEventsBookshelfPrivatePath = /private/FLOATEventsBookshelfPath
        self.FLOATEventsBookshelfPublicPath = /public/FLOATEventsBookshelfPath

        self.FLOATAchievementBoardStoragePath = /storage/FLOATAchievementBoardPath
        self.FLOATAchievementBoardPublicPath = /public/FLOATAchievementBoardPath

        emit ContractInitialized()
    }
}
