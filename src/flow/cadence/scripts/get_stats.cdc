import "FLOAT"

access(all) fun main(): Result {
    return Result(FLOAT.totalSupply, FLOAT.totalFLOATEvents)
}

access(all) struct Result {
    access(all) let floatTotalSupply: UInt64
    access(all) let eventsCreated: UInt64

    init(_ f: UInt64, _ e: UInt64) {
        self.floatTotalSupply = f
        self.eventsCreated = e
    }
}