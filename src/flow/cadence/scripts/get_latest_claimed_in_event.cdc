import "FLOAT"

access(all) fun main(account: Address, eventId: UInt64, amount: UInt64): [FLOAT.TokenIdentifier] {
  let answer: [FLOAT.TokenIdentifier] = []
  let floatEventCollection = getAccount(account).capabilities.borrow<&FLOAT.FLOATEvents>(FLOAT.FLOATEventsPublicPath)
                              ?? panic("Could not borrow the FLOAT Events Collection from the account.")
  let eventRef = floatEventCollection.borrowPublicEventRef(eventId: eventId)!
  let claims: [FLOAT.TokenIdentifier] = eventRef.getClaims().values

  if eventRef.totalSupply == 0 {
    return []
  }

  let latestSerial: UInt64 = eventRef.totalSupply - 1
  for claim in claims {
    if claim.serial + amount > latestSerial {
        answer.append(claim)
    }
  }
  return answer
}