import FLOAT from "../FLOAT.cdc"

transaction(id: UInt64) {

  let Collection: &FLOAT.Collection

  prepare(acct: AuthAccount) {
    self.Collection = acct.borrow<&FLOAT.Collection>(from: FLOAT.FLOATCollectionStoragePath)
                        ?? panic("Could not get the Collection from the signer.")
  }

  execute {
    self.Collection.delete(id: id)
    log("Destroyed the FLOAT.")
  }
}