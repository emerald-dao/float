import FLOAT from "../FLOAT.cdc"

pub fun main(): Result {
    return Result(FLOAT.totalSupply, FLOAT.totalFLOATEvents)
}

pub struct Result {
    pub let floatTotalSupply: UInt64
    pub let eventsCreated: UInt64

    init(_ f: UInt64, _ e: UInt64) {
        self.floatTotalSupply = f
        self.eventsCreated = e
    }
}