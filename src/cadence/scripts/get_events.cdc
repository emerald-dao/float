import FLOAT from "../FLOAT.cdc"

pub fun main(account: Address): {String: &FLOAT.FLOATEvent{FLOAT.FLOATEventPublic}} {
  let floatEventCollection = getAccount(account).getCapability(FLOAT.FLOATEventsPublicPath)
                              .borrow<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic}>()
                              ?? panic("Could not borrow the FLOAT Events Collection from the account.")
  let floatEvents: [UInt64] = floatEventCollection.getIDs()
  let returnVal: {String: &FLOAT.FLOATEvent{FLOAT.FLOATEventPublic}} = {}

  for eventId in floatEvents {
    let event = floatEventCollection.borrowPublicEventRef(eventId: eventId)
    returnVal[event.name] = event
  }
  return returnVal
}