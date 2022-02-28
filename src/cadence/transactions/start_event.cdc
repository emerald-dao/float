import FLOAT from "../FLOAT.cdc"
import NonFungibleToken from "../core-contracts/NonFungibleToken.cdc"
import MetadataViews from "../core-contracts/MetadataViews.cdc"
import FLOATVerifiers from "../FLOATVerifiers.cdc"

transaction(claimable: Bool, name: String, description: String, image: String, url: String, transferrable: Bool, timelock: Bool, dateStart: UFix64, timePeriod: UFix64, secret: Bool, secrets: [String], limited: Bool, capacity: UInt64) {

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
      acct.link<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic, MetadataViews.ResolverCollection}>
                (FLOAT.FLOATEventsPublicPath, target: FLOAT.FLOATEventsStoragePath)
    }

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
    self.FLOATEvents.createEvent(claimable: claimable, description: description, image: image, name: name, transferrable: transferrable, url: url, verifiers: verifiers, {})
    log("Started a new event.")
  }
}

