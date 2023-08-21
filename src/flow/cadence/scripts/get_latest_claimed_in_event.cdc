import FLOAT from "../FLOAT.cdc"

pub fun main(account: Address, eventId: UInt64, amount: UInt64): [FLOAT.TokenIdentifier] {
  let answer: [FLOAT.TokenIdentifier] = []
  let floatEventCollection = getAccount(account).getCapability(FLOAT.FLOATEventsPublicPath)
                              .borrow<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic}>()
                              ?? panic("Could not borrow the FLOAT Events Collection from the account.")
  let event = floatEventCollection.borrowPublicEventRef(eventId: eventId)!
  let claims: [FLOAT.TokenIdentifier] = event.getClaimed().values

  if event.totalSupply == 0 {
    return []
  }

  let latestSerial: UInt64 = event.totalSupply - 1
  for claim in claims {
    if claim.serial + amount > latestSerial {
        answer.append(claim)
    }
  }
  return answer
}