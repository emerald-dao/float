import FLOAT from "../FLOAT.cdc"
pub fun main(account: Address, eventIds: [UInt64]): [Bool] {
  let floatCollection = getAccount(account).getCapability(FLOAT.FLOATCollectionPublicPath)
                        .borrow<&FLOAT.Collection{FLOAT.CollectionPublic}>()
                        ?? panic("Could not borrow the Collection from the account.")
  
  let ret:[Bool] = []
  var i = 0
  while i < eventIds.length {
    ret.append(floatCollection.ownedIdsFromEvent(eventId: eventIds[i]).length > 0)
    i = i + 1
  }
  return ret
}