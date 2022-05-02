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

    // distrute reward by Lottery
    pub resource LotteryStrategy: FLOATEventsBook.ITreasuryStrategy {
        // strategy general controler
        access(account) let controller: @FLOATEventsBook.StrategyController

        init(controller: @FLOATEventsBook.StrategyController) {
            self.controller <- controller
        }

        destroy() {
            destroy self.controller
        }

        // check if strategy can go to claimable
        pub fun isReadyToClaimable(): Bool {
            // TODO
            return false
        }

        // invoked when state changed
        access(account) fun onStateChanged(state: FLOATEventsBook.StrategyState) {
            // TODO
        }

        // verify if the user match the strategy
        pub fun verifyClaimable(user: &{FLOATEventsBook.AchievementPublic}): Bool {
            // TODO
            return false
        }

        // update user's achievement
        access(account) fun updateAchievement(user: &{FLOATEventsBook.AchievementPublic}) {
            // TODO
        }
    }

    // distrute reward by queue
    pub resource ClaimingQueueStrategy: FLOATEventsBook.ITreasuryStrategy {
        // strategy general controler
        access(account) let controller: @FLOATEventsBook.StrategyController

        init(controller: @FLOATEventsBook.StrategyController) {
            self.controller <- controller
        }

        destroy() {
            destroy self.controller
        }

        // check if strategy can go to claimable
        pub fun isReadyToClaimable(): Bool {
            // TODO
            return false
        }

        // invoked when state changed
        access(account) fun onStateChanged(state: FLOATEventsBook.StrategyState) {
            // TODO
        }

        // verify if the user match the strategy
        pub fun verifyClaimable(user: &{FLOATEventsBook.AchievementPublic}): Bool {
            // TODO
            return false
        }

        // update user's achievement
        access(account) fun updateAchievement(user: &{FLOATEventsBook.AchievementPublic}) {
            // TODO
        }
    }
}
