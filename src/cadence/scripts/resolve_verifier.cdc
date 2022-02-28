import FLOAT from "../FLOAT.cdc"
import FLOATVerifiers from "../FLOATVerifiers.cdc"

pub fun main(account: Address, eventId: UInt64): [String] {
  let floatEventCollection = getAccount(account).getCapability(FLOAT.FLOATEventsPublicPath)
                              .borrow<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic}>()
                              ?? panic("Could not borrow the FLOAT Events Collection from the account.")
  let floatEvent: &FLOAT.FLOATEvent{FLOAT.FLOATEventPublic} = floatEventCollection.borrowPublicEventRef(eventId: eventId)
  let verifiers = floatEvent.getVerifiers()
  let answers: [String] = []

  for verifier in verifiers {
    answers.append(verifier.getType().identifier)
  }
  return answers
}