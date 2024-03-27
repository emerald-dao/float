import "FLOATIncinerator"
import "FLOAT"
import "NonFungibleToken"

transaction(id: UInt64) {
  let Collection: auth(NonFungibleToken.Owner) &FLOAT.Collection
  let Incinerator: auth(FLOATIncinerator.Owner) &FLOATIncinerator.Incinerator
  prepare(signer: auth(Storage, Capabilities) &Account) {
    self.Collection = signer.storage.borrow<auth(NonFungibleToken.Owner) &FLOAT.Collection>(from: FLOAT.FLOATCollectionStoragePath)
                        ?? panic("Could not get the Collection from the signer.")
  
    if signer.storage.borrow<&FLOATIncinerator.Incinerator>(from: FLOATIncinerator.IncineratorStoragePath) == nil {
      signer.storage.save(<- FLOATIncinerator.createIncinerator(), to: FLOATIncinerator.IncineratorStoragePath)
      let cap = signer.capabilities.storage.issue<&FLOATIncinerator.Incinerator>(FLOATIncinerator.IncineratorStoragePath)
      signer.capabilities.publish(cap, at: FLOATIncinerator.IncineratorPublicPath)
    }
    self.Incinerator = signer.storage.borrow<auth(FLOATIncinerator.Owner) &FLOATIncinerator.Incinerator>(from: FLOATIncinerator.IncineratorStoragePath)!
  }

  execute {
    let ids: [UInt64] = [id]
    self.Incinerator.burn(collection: self.Collection, ids: ids)
  }
}