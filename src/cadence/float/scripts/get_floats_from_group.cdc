import FLOAT from "../FLOAT.cdc"
pub fun main(host: Address, groupName: String, user: Address): Bool {
  let eventsCollection = getAccount(host).getCapability(FLOAT.FLOATEventsPublicPath)
                        .borrow<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic}>()
                        ?? panic("Could not borrow the FLOATEventsPublic from the host.")
  let group = eventsCollection.getGroup(groupName: groupName) ?? panic("This group does not exist.")
  let eventsInGroup = group.getEvents()

  let floatsCollection = getAccount(user).getCapability(FLOAT.FLOATCollectionPublicPath)
                        .borrow<&FLOAT.Collection{FLOAT.CollectionPublic}>()
                        ?? panic("Could not borrow the CollectionPublic from the user.")
  
  for eventId in eventsInGroup {
    if floatsCollection.ownedIdsFromEvent(eventId: eventId).length > 0 {
      return true
    }
  } 

  return false
}