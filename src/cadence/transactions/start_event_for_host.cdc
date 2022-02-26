import FLOAT from "../FLOAT.cdc"
import FLOATVerifiers from "../FLOATVerifiers.cdc"

transaction(forHost: Address, claimable: Bool, name: String, description: String, image: String, url: String, transferrable: Bool, timelock: Bool, dateStart: UFix64, timePeriod: UFix64, secret: Bool, secrets: [String], limited: Bool, capacity: UInt64) {

  let FLOATEvents: &FLOAT.FLOATEvents
  let SharedMinter: &FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic}

  prepare(acct: AuthAccount) {
    self.FLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                        ?? panic("Could not borrow the FLOATEvents from the signer.")
    self.SharedMinter = getAccount(forHost).getCapability(FLOAT.FLOATEventsPublicPath)
                          .borrow<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic}>()
                          ?? panic("Could not borrow the public FLOATEvents from forHost")
  }

  execute {
    let verifier = FLOATVerifiers.Verifier(_timelock: timelock, _dateStart: dateStart, _timePeriod: timePeriod, _limited: limited, _capacity: capacity, _secret: secret, _secrets: secrets)
    self.SharedMinter.createEventSharedMinter(claimable: claimable, description: description, image: image, name: name, transferrable: transferrable, url: url, verifier: verifier, {}, sharedMinter: self.FLOATEvents)
    log("Started a new event for host.")
  }
}  