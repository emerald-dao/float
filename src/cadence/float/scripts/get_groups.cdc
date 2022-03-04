import FLOAT from "../FLOAT.cdc"

pub fun main(account: Address): {String: FLOAT.Group} {
  let floatEventCollection = getAccount(account).getCapability(FLOAT.FLOATEventsPublicPath)
                              .borrow<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic}>()
                              ?? panic("Could not borrow the FLOAT Events Collection from the account.")
  let groups = floatEventCollection.getGroups()

  let answer: {String: FLOAT.Group} = {}
  for groupName in groups {
    answer[groupName] = floatEventCollection.getGroup(groupName: groupName)
  }

  return answer
}