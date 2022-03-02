import FLOAT from "../FLOAT.cdc"
import MetadataViews from "../core-contracts/MetadataViews.cdc"

pub fun main(account: Address, eventId: UInt64): [String] {
  let floatEventCollection = getAccount(account).getCapability(FLOAT.FLOATEventsPublicPath)
                              .borrow<&FLOAT.FLOATEvents{MetadataViews.ResolverCollection}>()
                              ?? panic("Could not borrow the FLOAT Events Collection from the account.")
  let resolved = floatEventCollection.borrowViewResolver(id: eventId)
  if let view = resolved.resolveView(Type<FLOAT.FLOATEventMetadata>()) {
    let metadata = view as! FLOAT.FLOATEventMetadata
    let answer: [String] = []
    for verifier in metadata.verifiers {
      answer.append(verifier.getType().identifier)
    }
  }
  return []
}