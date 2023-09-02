import FLOAT from "../FLOAT.cdc"
import FLOATVerifiers from "../FLOATVerifiers.cdc"
import NonFungibleToken from "../utility/NonFungibleToken.cdc"
import MetadataViews from "../utility/MetadataViews.cdc"

transaction(
  name: String, 
  description: String, 
  url: String, 
  logo: String,
  backImage: String,
  certificateImage: String,
  transferrable: Bool,
  claimable: Bool, 
  eventType: String,
  certificateType: String,
  timelockToggle: Bool, 
  dateStart: UFix64, 
  timePeriod: UFix64, 
  secretToggle: Bool, 
  secretPK: String, 
  limitedToggle: Bool, 
  capacity: UInt64, 
  flowTokenPurchaseToggle: Bool, 
  flowTokenCost: UFix64,
  minimumBalanceToggle: Bool,
  minimumBalance: UFix64
) {

  let FLOATEvents: &FLOAT.FLOATEvents

  prepare(acct: AuthAccount) {
    // SETUP COLLECTION
    if acct.borrow<&FLOAT.Collection>(from: FLOAT.FLOATCollectionStoragePath) == nil {
        acct.save(<- FLOAT.createEmptyCollection(), to: FLOAT.FLOATCollectionStoragePath)
        acct.link<&FLOAT.Collection{NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection, FLOAT.CollectionPublic}>
                (FLOAT.FLOATCollectionPublicPath, target: FLOAT.FLOATCollectionStoragePath)
    }

    // SETUP FLOATEVENTS
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
    var SecretV2: FLOATVerifiers.SecretV2? = nil
    var Limited: FLOATVerifiers.Limited? = nil
    var MinimumBalance: FLOATVerifiers.MinimumBalance? = nil

    var verifiers: [{FLOAT.IVerifier}] = []
    if timelockToggle {
      Timelock = FLOATVerifiers.Timelock(_dateStart: dateStart, _timePeriod: timePeriod)
      verifiers.append(Timelock!)
    }
    if secretToggle {
      SecretV2 = FLOATVerifiers.SecretV2(_publicKey: secretPK)
      verifiers.append(SecretV2!)
    }
    if limitedToggle {
      Limited = FLOATVerifiers.Limited(_capacity: capacity)
      verifiers.append(Limited!)
    }
    if minimumBalanceToggle {
      MinimumBalance = FLOATVerifiers.MinimumBalance(_amount: minimumBalance)
      verifiers.append(MinimumBalance!)
    }

    let extraMetadata: {String: AnyStruct} = {}
    if flowTokenPurchaseToggle {
      let tokenInfo = FLOAT.TokenInfo(_path: /public/flowTokenReceiver, _price: flowTokenCost)
      extraMetadata["prices"] = {"${flowTokenIdentifier}.FlowToken.Vault": tokenInfo}
    }
    extraMetadata["backImage"] = backImage
    extraMetadata["eventType"] = eventType
    extraMetadata["certificateType"] = certificateType
    extraMetadata["certificateImage"] = certificateImage

    self.FLOATEvents.createEvent(claimable: claimable, description: description, image: logo, name: name, transferrable: transferrable, url: url, verifiers: verifiers, extraMetadata)
    log("Started a new event for host.")
  }
}
