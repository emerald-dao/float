import FLOAT from "../FLOAT.cdc"
pub fun main(host: Address, groupName: String, user: Address): {UInt64: [UInt64]} {
  let eventsCollection = getAccount(host).getCapability(FLOAT.FLOATEventsPublicPath)
                        .borrow<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic}>()
                        ?? panic("Could not borrow the FLOATEventsPublic from the host.")
  let group = eventsCollection.getGroup(groupName: groupName) ?? panic("This group does not exist.")
  let eventsInGroup = group.getEvents()

  let floatsCollection = getAccount(user).getCapability(FLOAT.FLOATCollectionPublicPath)
                        .borrow<&FLOAT.Collection{FLOAT.CollectionPublic}>()
                        ?? panic("Could not borrow the CollectionPublic from the user.")
  
  let answer: {UInt64: [UInt64]} = {}
  for eventId in eventsInGroup {
    answer[eventId] = floatsCollection.ownedIdsFromEvent(eventId: eventId)
  } 

  return answer
}