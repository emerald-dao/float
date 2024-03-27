import "FLOAT"
import "NonFungibleToken"
import "MetadataViews"

transaction(eventId: UInt64, host: Address, secretSig: String?, emailSig: String?) {
 
  let FLOATEvent: &FLOAT.FLOATEvent
  let Collection: &FLOAT.Collection

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

    let FLOATEvents: &FLOAT.FLOATEvents = getAccount(host).capabilities.borrow<&FLOAT.FLOATEvents>(FLOAT.FLOATEventsPublicPath)
                        ?? panic("Could not borrow the public FLOATEvents from the host.")
    self.FLOATEvent = FLOATEvents.borrowPublicEventRef(eventId: eventId) ?? panic("This event does not exist.")

    self.Collection = account.storage.borrow<&FLOAT.Collection>(from: FLOAT.FLOATCollectionStoragePath)
                        ?? panic("Could not get the Collection from the signer.")
  }

  execute {
    let params: {String: AnyStruct} = {}

    // If the FLOAT has a secret phrase on it
    if let unwrappedSecret = secretSig {
      params["secretSig"] = unwrappedSecret
    }
    if let unwrappedEmailSig = emailSig {
      params["emailSig"] = unwrappedEmailSig
    }
 
    self.FLOATEvent.claim(recipient: self.Collection, params: params)
    log("Claimed the FLOAT.")
  }
}
 