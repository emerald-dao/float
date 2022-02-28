import FLOAT from "../FLOAT.cdc"
import FLOATVerifiers from "../FLOATVerifiers.cdc"

transaction(forHost: Address, claimable: Bool, name: String, description: String, image: String, url: String, transferrable: Bool, timelock: Bool, dateStart: UFix64, timePeriod: UFix64, secret: Bool, secrets: [String], limited: Bool, capacity: UInt64) {

  let FLOATEvents: &FLOAT.FLOATEvents

  prepare(acct: AuthAccount) {
    self.FLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                        ?? panic("Could not borrow the FLOATEvents from the signer.")
  }

  execute {
    var Timelock: FLOATVerifiers.Timelock? = nil
    var Secret: FLOATVerifiers.Secret? = nil
    var Limited: FLOATVerifiers.Limited? = nil
    var MultipleSecret: FLOATVerifiers.MultipleSecret? = nil
    var verifiers: [{FLOAT.IVerifier}] = []
    if timelock {
      Timelock = FLOATVerifiers.Timelock(_dateStart: dateStart, _timePeriod: timePeriod)
      verifiers.append(Timelock!)
    }
    if secret {
      if secrets.length == 1 {
        Secret = FLOATVerifiers.Secret(_secretPhrase: secrets[0])
        verifiers.append(Secret!)
      } else {
        MultipleSecret = FLOATVerifiers.MultipleSecret(_secrets: secrets)
        verifiers.append(MultipleSecret!)
      }
    }
    if limited {
      Limited = FLOATVerifiers.Limited(_capacity: capacity)
      verifiers.append(Limited!)
    }
    self.FLOATEvents.createEventSharedMinter(forHost: forHost, claimable: claimable, description: description, image: image, name: name, transferrable: transferrable, url: url, verifiers: verifiers, {})
    log("Started a new event for host.")
  }
}  