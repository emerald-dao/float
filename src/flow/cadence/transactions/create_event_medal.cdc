import "FLOAT"
import "FLOATVerifiers"
import "NonFungibleToken"
import "MetadataViews"
import "FlowToken"

transaction(
  name: String, 
  description: String, 
  url: String, 
  logo: String,
  backImage: String,
  certificateImages: {String: String},
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
  minimumBalance: UFix64,
  requireEmail: Bool,
  emailVerifierPublicKey: String,
  visibilityMode: String, // "certificate" or "picture"
  allowMultipleClaim: Bool
) {

  let FLOATEvents: auth(FLOAT.EventsOwner) &FLOAT.FLOATEvents

  prepare(account: auth(Storage, Capabilities) &Account) {
    // SETUP COLLECTION
    if account.storage.borrow<&FLOAT.Collection>(from: FLOAT.FLOATCollectionStoragePath) == nil {
      account.capabilities.unpublish(FLOAT.FLOATCollectionPublicPath)
      account.storage.save(<- FLOAT.createEmptyCollection(nftType: Type<@FLOAT.NFT>()), to: FLOAT.FLOATCollectionStoragePath)
      let collectionCap = account.capabilities.storage.issue<&FLOAT.Collection>(FLOAT.FLOATCollectionStoragePath)
      account.capabilities.publish(collectionCap, at: FLOAT.FLOATCollectionPublicPath)
    }

    // SETUP FLOATEVENTS
    if account.storage.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath) == nil {
      account.capabilities.unpublish(FLOAT.FLOATEventsPublicPath)
      account.storage.save(<- FLOAT.createEmptyFLOATEventCollection(), to: FLOAT.FLOATEventsStoragePath)
      let eventsCap = account.capabilities.storage.issue<&FLOAT.FLOATEvents>(FLOAT.FLOATEventsStoragePath)
      account.capabilities.publish(eventsCap, at: FLOAT.FLOATEventsPublicPath)
    }

    self.FLOATEvents = account.storage.borrow<auth(FLOAT.EventsOwner) &FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                      ?? panic("Could not borrow the FLOATEvents from the signer.")
  }

  execute {
    var verifiers: [{FLOAT.IVerifier}] = []
    if timelockToggle {
      let Timelock = FLOATVerifiers.Timelock(_dateStart: dateStart, _timePeriod: timePeriod)
      verifiers.append(Timelock)
    }
    if secretToggle {
      let SecretV2 = FLOATVerifiers.SecretV2(_publicKey: secretPK)
      verifiers.append(SecretV2)
    }
    if limitedToggle {
      let Limited = FLOATVerifiers.Limited(_capacity: capacity)
      verifiers.append(Limited)
    }
    if minimumBalanceToggle {
      let MinimumBalance = FLOATVerifiers.MinimumBalance(_amount: minimumBalance)
      verifiers.append(MinimumBalance)
    }
    if requireEmail {
      let Email = FLOATVerifiers.Email(_publicKey: emailVerifierPublicKey)
      verifiers.append(Email)
    }

    let extraMetadata: {String: AnyStruct} = {}
    if flowTokenPurchaseToggle {
      let tokenInfo: FLOAT.TokenInfo = FLOAT.TokenInfo(_path: /public/flowTokenReceiver, _price: flowTokenCost)
      let flowTokenVaultIdentifier: String = Type<@FlowToken.Vault>().identifier
      extraMetadata["prices"] = {flowTokenVaultIdentifier: tokenInfo}
    }
    extraMetadata["backImage"] = backImage
    extraMetadata["eventType"] = eventType
    for medalType in certificateImages.keys {
      extraMetadata["certificateImage.".concat(medalType)] = certificateImages[medalType]
    }

    self.FLOATEvents.createEvent(
      claimable: claimable, 
      description: description, 
      image: logo, 
      name: name, 
      transferrable: transferrable, 
      url: url, 
      verifiers: verifiers, 
      allowMultipleClaim: allowMultipleClaim,
      certificateType: certificateType,
      visibilityMode: visibilityMode,
      extraMetadata: extraMetadata
    )
    log("Started a new event for host.")
  }
}
