import FLOAT from "../FLOAT.cdc"
import NonFungibleToken from "../core-contracts/NonFungibleToken.cdc"
import MetadataViews from "../core-contracts/MetadataViews.cdc"

transaction(forHost: Address, claimable: Bool, name: String, description: String, image: String, url: String, transferrable: Bool, timelock: Bool, dateStart: UFix64, timePeriod: UFix64, secret: Bool, secretPhrase: String, limited: Bool, capacity: UInt64) {

  let SharedMinter: &FLOAT.FLOATEvents

  prepare(acct: AuthAccount) {
    let FLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                        ?? panic("Could not borrow the FLOATEvents from the signer.")
    self.SharedMinter = FLOATEvents.getSharedMinterRef(host: forHost) 
                          ?? panic("You do not have access to this host's minting rights.")
  }

  execute {
    var Timelock: FLOAT.Timelock? = nil
    var Secret: FLOAT.Secret? = nil
    var Limited: FLOAT.Limited? = nil
    
    if timelock {
      Timelock = FLOAT.Timelock(_dateStart: dateStart, _timePeriod: timePeriod)
    }
    
    if secret {
      Secret = FLOAT.Secret(_secretPhrase: secretPhrase)
    }

    if limited  {
      Limited = FLOAT.Limited(_capacity: capacity)
    }
    
    self.SharedMinter.createEvent(claimable: claimable, description: description, image: image, limited: Limited, name: name, secret: Secret, timelock: Timelock, transferrable: transferrable, url: url, {})
    log("Started a new event.")
  }
}  