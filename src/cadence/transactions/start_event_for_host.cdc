import FLOAT from "../FLOAT.cdc"
import FLOATVerifiers from "../FLOATVerifiers.cdc"

transaction(forHost: Address, claimable: Bool, name: String, description: String, image: String, url: String, transferrable: Bool, timelock: Bool, dateStart: UFix64, timePeriod: UFix64, secret: Bool, secrets: [String], limited: Bool, capacity: UInt64) {

  let SharedMinter: &FLOAT.FLOATEvents

  prepare(acct: AuthAccount) {
    let FLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                        ?? panic("Could not borrow the FLOATEvents from the signer.")
    self.SharedMinter = FLOATEvents.getSharedMinterRef(host: forHost) 
                          ?? panic("You do not have access to this host's minting rights.")
  }

  execute {
    let verifier = FLOATVerifiers.Verifier(_timelock: timelock, _dateStart: dateStart, _timePeriod: timePeriod, _limited: limited, _capacity: capacity, _secret: secret, _secrets: secrets)
    self.SharedMinter.createEvent(claimable: claimable, description: description, image: image, name: name, transferrable: transferrable, url: url, verifier: verifier, {})
    log("Started a new event for host.")
  }
}  