import FLOAT from "../FLOAT.cdc"
import MetadataViews from "../core-contracts/MetadataViews.cdc"
import FLOATMetadataViews from "../FLOATMetadataViews.cdc"
import FLOATVerifiers from "../FLOATVerifiers.cdc"

pub fun main(account: Address, id: UInt64): {String: AnyStruct} {
  let floatEventCollection = getAccount(account).getCapability(FLOAT.FLOATEventsPublicPath)
                              .borrow<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic, MetadataViews.ResolverCollection}>()
                              ?? panic("Could not borrow the FLOAT Events Collection from the account.")
  let publicRef: &FLOAT.FLOATEvent{FLOAT.FLOATEventPublic} = floatEventCollection.getPublicEventRef(id: id)
  let verifier = publicRef.verifier as! FLOATVerifiers.Verifier
  let answers: {String: AnyStruct} = {}

  if let timelock = verifier.timelock {
    answers["dateStart"] = timelock.dateStart
    answers["dateEnding"] = timelock.dateEnding
  }

  if let limited = verifier.limited {
    answers["capacity"] = limited.capacity
  }
  return answers
}