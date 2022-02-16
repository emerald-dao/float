import FLOAT from "../FLOAT.cdc"
import NonFungibleToken from "../core-contracts/NonFungibleToken.cdc"
import MetadataViews from "../core-contracts/MetadataViews.cdc"

transaction(claimable: Bool, name: String, description: String, image: String, url: String, transferrable: Bool, timelock: Bool, dateStart: UFix64, timePeriod: UFix64, secret: Bool, secretPhrase: String, limited: Bool, capacity: UInt64) {

  let FLOATEvents: &FLOAT.FLOATEvents

  prepare(acct: AuthAccount) {
    // set up the FLOAT Collection where users will store their FLOATs
    if acct.borrow<&FLOAT.Collection>(from: FLOAT.FLOATCollectionStoragePath) == nil {
        acct.save(<- FLOAT.createEmptyCollection(), to: FLOAT.FLOATCollectionStoragePath)
        acct.link<&FLOAT.Collection{NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection}>
                (FLOAT.FLOATCollectionPublicPath, target: FLOAT.FLOATCollectionStoragePath)
    }

    // set up the FLOAT Events where users will store all their created events
    if acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath) == nil {
      acct.save(<- FLOAT.createEmptyFLOATEventCollection(), to: FLOAT.FLOATEventsStoragePath)
      acct.link<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic, FLOAT.FLOATEventsContract, MetadataViews.ResolverCollection}>(FLOAT.FLOATEventsPublicPath, target: FLOAT.FLOATEventsStoragePath)
    }

    self.FLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                        ?? panic("Could not borrow the FLOATEvents from the signer.")
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
    
    self.FLOATEvents.createEvent(claimable: claimable, description: description, image: image, limited: Limited, name: name, secret: Secret, timelock: Timelock, transferrable: transferrable, url: url, {})
    log("Started a new event.")
  }
}  