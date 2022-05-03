import FLOATEventsBook from "./FLOATEventsBook.cdc"

pub contract FLOATStrategies {

    // Accomplish goal when a certain amount is collected
    pub struct CollectByAmountGoal: FLOATEventsBook.IAchievementGoal {
        // achievement title
        pub let title: String
        // variables
        access(self) let points: UInt64
        access(self) let amount: UInt64
        access(self) let requiredAmount: UInt64

        init(
            points: UInt64,
            amount: UInt64,
            requiredAmount: UInt64?
        ) {
            pre {
                (requiredAmount ?? 0) <= amount: "required amount should be less then amount."
            }
            self.points = points
            self.amount = amount
            self.requiredAmount = requiredAmount ?? 0

            self.title = "Collect ".concat(amount.toString()).concat(" FLOATs.")
        }

        pub fun getPoints(): UInt64 { return self.points }

        pub fun getGoalDetail(): {String: AnyStruct} {
            let ret: {String: UInt64} = {}
            ret["amount"] = self.amount
            ret["requiredAmount"] = self.requiredAmount
            return ret
        }

        // Check if user fits some criteria.
        access(account) fun verify(_ eventsBook: &{FLOATEventsBook.EventsBookPublic}, user: Address): Bool {
            var claimedTotal: UInt64 = 0
            var claimedRequired: UInt64 = 0

            let slots = eventsBook.getSlots()
            for slot in slots {
                if let eventIdentifier = slot.getIdentifier() {
                    let eventPub = eventIdentifier.getEventPublic()
                    // check if FLOAT is claimed
                    let token = eventPub.hasClaimed(account: user)
                    if token != nil {
                        claimedTotal = claimedTotal + 1
                        // required update
                        if slot.isEventRequired() {
                            claimedRequired = claimedRequired + 1
                        }
                    }
                }
            }
            return claimedTotal >= self.amount && claimedRequired >= self.requiredAmount
        }
    }
    
    // Accomplish goal when a certain percent is collected
    pub struct CollectByPercentGoal: FLOATEventsBook.IAchievementGoal {
        // achievement title
        pub let title: String
        // variables
        access(self) let points: UInt64
        access(self) let percent: UFix64

        init(
            points: UInt64,
            percentToCollect: UFix64
        ) {
            self.points = points
            self.percent = percentToCollect

            self.title = "Collect ".concat(percentToCollect.toString()).concat("% of all FLOATs.")
        }

        pub fun getPoints(): UInt64 { return self.points }

        pub fun getGoalDetail(): {String: AnyStruct} {
            let ret: {String: UFix64} = {}
            ret["percent"] = self.percent
            return ret
        }

        // Check if user fits some criteria.
        access(account) fun verify(_ eventsBook: &{FLOATEventsBook.EventsBookPublic}, user: Address): Bool {
            var claimedTotal: UFix64 = 0.0
            var slotTotal: UFix64 = 0.0

            let slots = eventsBook.getSlots()
            for slot in slots {
                slotTotal = slotTotal + 1.0
                if let eventIdentifier = slot.getIdentifier() {
                    let eventPub = eventIdentifier.getEventPublic()
                    // check if FLOAT is claimed
                    let token = eventPub.hasClaimed(account: user)
                    if token != nil {
                        claimedTotal = claimedTotal + 1.0
                    }
                }
            }
            return claimedTotal / slotTotal >= self.percent
        }
    }
 
    // Accomplish goal when some FLOATs are collected
    pub struct CollectSpecialFLOATsGoal: FLOATEventsBook.IAchievementGoal {
        // achievement title
        pub let title: String
        // variables
        access(self) let points: UInt64
        access(self) let floats: [FLOATEventsBook.EventIdentifier]

        init(
            points: UInt64,
            floats: [FLOATEventsBook.EventIdentifier]
        ) {
            self.points = points
            self.floats = floats

            self.title = "Collect some specific FLOATs."
        }

        pub fun getPoints(): UInt64 { return self.points }

        pub fun getGoalDetail(): {String: AnyStruct} {
            let ret: {String: [FLOATEventsBook.EventIdentifier]} = {}
            ret["floats"] = self.floats
            return ret
        } 

        // Check if user fits some criteria.
        access(account) fun verify(_ eventsBook: &{FLOATEventsBook.EventsBookPublic}, user: Address): Bool {
            let requiredIDs: [String] = []
            for requiredFloat in self.floats {
                requiredIDs.append(requiredFloat.toString())
            }
            var claimedTotal: Int = 0

            let slots = eventsBook.getSlots()
            for slot in slots {
                if let eventIdentifier = slot.getIdentifier() {
                    // only required
                    if requiredIDs.contains(eventIdentifier.toString()) {
                        let eventPub = eventIdentifier.getEventPublic()
                        // check if FLOAT is claimed
                        let token = eventPub.hasClaimed(account: user)
                        if token != nil {
                            claimedTotal = claimedTotal + 1
                        }
                    }
                }
            }
            return claimedTotal == requiredIDs.length
        }
    }

    pub enum StrategyType: UInt8 {
        pub case Lottery
        pub case ClaimingQueue
    }

    // Strategy parameter
    pub struct LotteryDetail {
        // minimium valid users reached
        pub let minimiumValid: UInt64
        // datetimes ending to limit
        pub let ending: {FLOATEventsBook.StrategyState: UFix64}
        // valid users to do a lottery
        pub let valid: [Address]
        // lottery winners
        pub let winners: [Address]
        // winners who has claimed rewards
        pub let claimed: [Address]

        init(
            _ minValid: UInt64,
            _ ending: {FLOATEventsBook.StrategyState: UFix64},
            _ valid: [Address],
            _ winners: [Address],
            _ claimed: [Address]
        ) {
            self.minimiumValid = minValid
            self.ending = ending
            self.valid = valid
            self.winners = winners
            self.claimed = claimed
        }
    }

    // distrute reward by Lottery
    pub resource LotteryStrategy: FLOATEventsBook.ITreasuryStrategy {
        // strategy general controller
        access(account) let controller: @FLOATEventsBook.StrategyController
        access(self) let params: {String: AnyStruct}

        access(self) let minimiumValid: UInt64
        access(self) let ending: {FLOATEventsBook.StrategyState: UFix64}
        access(self) var valid: [Address]
        access(self) var winners: [Address]
        access(self) var claimed: [Address]

        init(
            controller: @FLOATEventsBook.StrategyController,
            params: {String: AnyStruct}
        ) {
            self.controller <- controller
            self.params = params

            let info = self.controller.getInfo()
            if let value = params["minValid"] {
                self.minimiumValid = value as! UInt64
            } else {
                self.minimiumValid = info.maxClaimableAmount
            }

            self.ending = FLOATStrategies.parseStrategyTime(params)

            self.valid = []
            self.winners = []
            self.claimed = []
        }

        destroy() {
            destroy self.controller
        }

        // Fetch detail of the strategy
        pub fun getStrategyDetail(): LotteryDetail {
            return LotteryDetail(self.minimiumValid, self.ending, self.valid, self.winners, self.claimed)
        }

        // invoked when state changed
        access(account) fun onStateChanged(state: FLOATEventsBook.StrategyState) {
            // TODO
        }

        // ---------- opening Stage ----------

        // check if strategy can go to claimable
        pub fun isReadyToClaimable(): Bool {
            let validUserAmount = self.valid.length
            let now = getCurrentBlock().timestamp
            return UInt64(validUserAmount) >= self.minimiumValid && now <= (self.ending[FLOATEventsBook.StrategyState.opening] ?? now)
        }

        // update user's achievement
        access(account) fun onGoalAccomplished(user: &{FLOATEventsBook.AchievementPublic}) {
            // TODO
        }

        // ---------- claimable Stage ----------

        // verify if the user match the strategy
        pub fun verifyClaimable(user: &{FLOATEventsBook.AchievementPublic}): Bool {
            let now = getCurrentBlock().timestamp
            assert(now <= (self.ending[FLOATEventsBook.StrategyState.claimable] ?? now), message: "Sorry! The claimable ending time is ran out.")

            return self.valid.contains(user.getOwner())
        }
    }
    
    // Strategy parameter
    pub struct ClaimingQueueDetail {

        init() {

        }
    }

    // distrute reward by queue
    pub resource ClaimingQueueStrategy: FLOATEventsBook.ITreasuryStrategy {
        // strategy general controller
        access(account) let controller: @FLOATEventsBook.StrategyController

        init( 
            controller: @FLOATEventsBook.StrategyController,
            params: {String: AnyStruct}
        ) {
            self.controller <- controller
        }

        destroy() {
            destroy self.controller
        }

        // Fetch detail of the strategy
        pub fun getStrategyDetail(): ClaimingQueueDetail {
            return ClaimingQueueDetail()
        }

        // invoked when state changed
        access(account) fun onStateChanged(state: FLOATEventsBook.StrategyState) {
            // TODO
        }

        // ---------- opening Stage ----------

        // check if strategy can go to claimable
        pub fun isReadyToClaimable(): Bool {
            // TODO
            return false
        }

        // update user's achievement
        access(account) fun onGoalAccomplished(user: &{FLOATEventsBook.AchievementPublic}) {
            // TODO
        }
        // ---------- claimable Stage ----------

        // verify if the user match the strategy
        pub fun verifyClaimable(user: &{FLOATEventsBook.AchievementPublic}): Bool {
            // TODO
            return false
        }
    }

    // parse strategy ending time from params
    access(contract) fun parseStrategyTime(_ params: {String: AnyStruct}): {FLOATEventsBook.StrategyState: UFix64} {
        let ending: {FLOATEventsBook.StrategyState: UFix64} = {}
        let now = getCurrentBlock().timestamp

        if let value = params["openingEnd"] {
            let timestamp = value as! UFix64
            assert(now <= timestamp, message: "Sorry! The openingEnd time has run out")
            ending[FLOATEventsBook.StrategyState.opening] = timestamp
        }

        if let value = params["claimableEnd"] {
            let timestamp = value as! UFix64
            assert(now <= timestamp, message: "Sorry! The claimableEnd time has run out")
            ending[FLOATEventsBook.StrategyState.claimable] = timestamp
        }

        return ending
    }

    // Strategy factory method
    pub fun createStrategy(
        type: StrategyType,
        controller: @FLOATEventsBook.StrategyController,
        params: {String: AnyStruct}
    ): @{FLOATEventsBook.ITreasuryStrategy}? {
        switch type {
        case StrategyType.Lottery:
            return <- create LotteryStrategy(controller: <- controller, params: params)
        case StrategyType.ClaimingQueue:
            return <- create ClaimingQueueStrategy(controller: <- controller, params: params)
        default:
            destroy controller
            return nil
        }
    }
}
