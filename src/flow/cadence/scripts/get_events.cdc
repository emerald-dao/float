import FLOAT from "../FLOAT.cdc"
import FLOATVerifiers from "../FLOATVerifiers.cdc"
import FlowToken from "../utility/FlowToken.cdc"

pub fun main(account: Address): [FLOATEventMetadata] {
  let floatEventCollection = getAccount(account).getCapability(FLOAT.FLOATEventsPublicPath)
                              .borrow<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic}>()
                              ?? panic("Could not borrow the FLOAT Events Collection from the account.")
  let floatEvents: [UInt64] = floatEventCollection.getIDs() 
  let returnVal: [FLOATEventMetadata] = []

  for eventId in floatEvents {
    let event = floatEventCollection.borrowPublicEventRef(eventId: eventId) ?? panic("This event does not exist in the account")
    let metadata = FLOATEventMetadata(event)
    returnVal.append(metadata)
  }
  return returnVal
}

pub struct FLOATEventMetadata {
  pub let claimable: Bool
  pub let dateCreated: UFix64
  pub let description: String 
  pub let eventId: UInt64
  pub let host: Address
  pub let backImage: String?
  pub let image: String 
  pub let name: String
  pub let totalSupply: UInt64
  pub let transferrable: Bool
  pub let url: String
  pub let verifiers: [AnyStruct]
  pub let eventType: String
  pub let price: UFix64?

  init(_ event: &FLOAT.FLOATEvent{FLOAT.FLOATEventPublic}) {
      self.claimable = event.claimable
      self.dateCreated = event.dateCreated
      self.description = event.description
      self.eventId = event.eventId
      let extraMetadata = event.getExtraMetadata()
      self.host = event.host
      if let backImage = extraMetadata["backImage"] as! String? {
        self.backImage = "https://ipfs.io/ipfs/".concat(backImage)
      } else {
        self.backImage = nil
      }
      self.image = "https://ipfs.io/ipfs/".concat(event.image)
      self.name = event.name
      self.transferrable = event.transferrable
      self.totalSupply = event.totalSupply
      self.url = event.url
      let verifiers = event.getVerifiers()
      self.verifiers = []
      if let timelock = verifiers[Type<FLOATVerifiers.Timelock>().identifier] {
        if timelock.length > 0 {
          self.verifiers.append(timelock[0])
        }
      }
      if let minBalance = verifiers[Type<FLOATVerifiers.MinimumBalance>().identifier] {
        if minBalance.length > 0 {
          self.verifiers.append(minBalance[0])
        }
      }
      if let secret = verifiers[Type<FLOATVerifiers.SecretV2>().identifier] {
        if secret.length > 0 {
          self.verifiers.append(secret[0])
        }
      }
      if let limited = verifiers[Type<FLOATVerifiers.Limited>().identifier] {
        if limited.length > 0 {
          self.verifiers.append(limited[0])
        }
      }
      self.eventType = (extraMetadata["eventType"] as! String?) ?? "other"

      if let prices = event.getPrices() {
        let flowTokenVaultIdentifier = Type<@FlowToken.Vault>().identifier
        self.price = prices[flowTokenVaultIdentifier]?.price
      } else {
        self.price = nil
      }
  }
}