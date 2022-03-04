import FLOAT from "../FLOAT.cdc"
import MetadataViews from "../../core-contracts/MetadataViews.cdc"

pub fun main(account: Address, groupName: String): [FLOAT.FLOATEventMetadata] {
  let floatEventCollection = getAccount(account).getCapability(FLOAT.FLOATEventsPublicPath)
                              .borrow<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic, MetadataViews.ResolverCollection}>()
                              ?? panic("Could not borrow the FLOAT Events Collection from the account.")
  let group = floatEventCollection.getGroup(groupName: groupName)
  let eventIds = group.getEvents()

  let answer: [FLOAT.FLOATEventMetadata] = []
  for eventId in eventIds {
    let resolver = floatEventCollection.borrowViewResolver(id: eventId)
    let view = resolver.resolveView(Type<FLOAT.FLOATEventMetadata>())! as! FLOAT.FLOATEventMetadata
    answer.append(view)
  }

  return answer
}