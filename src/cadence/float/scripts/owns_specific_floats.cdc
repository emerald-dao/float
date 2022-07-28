import FLOAT from "../FLOAT.cdc"
pub fun main(account: Address, eventIds: [UInt64]): Bool {
  let floatCollection = getAccount(account).getCapability(FLOAT.FLOATCollectionPublicPath)
                        .borrow<&FLOAT.Collection{FLOAT.CollectionPublic}>()
                        ?? panic("Could not borrow the Collection from the account.")
  
  for eventId in eventIds {
    if floatCollection.ownedIdsFromEvent(eventId: eventId).length == 0 {
      return false
    }
  }
  return true
}