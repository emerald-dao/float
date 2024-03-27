import "FLOAT"
import "NonFungibleToken"
import "MetadataViews"

transaction() {
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
  }
}
