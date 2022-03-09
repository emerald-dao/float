import FLOAT from "../FLOAT.cdc"
pub fun main(account: Address, eventId: UInt64): [&FLOAT.NFT] {
  let floatCollection = getAccount(account).getCapability(FLOAT.FLOATCollectionPublicPath)
                        .borrow<&FLOAT.Collection{FLOAT.CollectionPublic}>()
                        ?? panic("Could not borrow the Collection from the account.")
  return floatCollection.ownedFLOATsFromEvent(eventId: eventId)
}