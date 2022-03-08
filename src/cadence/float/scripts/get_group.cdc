import FLOAT from "../FLOAT.cdc"

pub fun main(account: Address, groupName: String): FLOAT.Group? {
  let floatEventCollection = getAccount(account).getCapability(FLOAT.FLOATEventsPublicPath)
                              .borrow<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic}>()
                              ?? panic("Could not borrow the FLOAT Events Collection from the account.")
  return floatEventCollection.getGroup(groupName: groupName)
}