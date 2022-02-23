import FLOAT from "../FLOAT.cdc"

pub fun main(account: Address): {UInt64: &FLOAT.NFT} {
  let floatCollection = getAccount(account).getCapability(FLOAT.FLOATCollectionPublicPath)
                        .borrow<&FLOAT.Collection{FLOAT.CollectionPublic}>()
                        ?? panic("Could not borrow the Collection from the account.")
  let floats = floatCollection.getIDs()
  var returnVal: {UInt64: &FLOAT.NFT} = {}
  for id in floats {
    returnVal[id] = floatCollection.borrowFLOAT(id: id)
  }

  return returnVal
}