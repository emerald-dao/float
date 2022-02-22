import FLOAT from "../FLOAT.cdc"
import MetadataViews from "../core-contracts/MetadataViews.cdc"
import FLOATMetadataViews from "../FLOATMetadataViews.cdc"
import FLOATVerifiers from "../FLOATVerifiers.cdc"

pub fun main(account: Address, id: UInt64): {String: AnyStruct} {
  let floatEventCollection = getAccount(account).getCapability(FLOAT.FLOATEventsPublicPath)
                              .borrow<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic, MetadataViews.ResolverCollection}>()
                              ?? panic("Could not borrow the FLOAT Events Collection from the account.")
  let publicRef = floatEventCollection.getPublicEventRef(id: id)
  let answers: {String: AnyStruct} = {}

  if let timelockView = publicRef.verifierResolveView(view: Type<FLOATVerifiers.Timelock>()) {
    let timelock = timelockView as! FLOATVerifiers.Timelock
    answers["dateStart"] = timelock.dateStart
    answers["dateEnding"] = timelock.dateEnding
  }

  if let limitedView = publicRef.verifierResolveView(view: Type<FLOATVerifiers.Limited>()) {
    let limited = limitedView as! FLOATVerifiers.Limited
    answers["capacity"] = limited.capacity
  }
  return answers
}