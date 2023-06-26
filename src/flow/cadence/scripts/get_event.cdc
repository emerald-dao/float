import FLOAT from "../FLOAT.cdc"
import FlowToken from "../utility/FlowToken.cdc"

pub fun main(account: Address, eventId: UInt64): FLOATEventMetadata {
  let floatEventCollection = getAccount(account).getCapability(FLOAT.FLOATEventsPublicPath)
                              .borrow<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic}>()
                              ?? panic("Could not borrow the FLOAT Events Collection from the account.")

  let event = floatEventCollection.borrowPublicEventRef(eventId: eventId) ?? panic("This event does not exist in the account")
  let metadata = FLOATEventMetadata(event)
  return metadata
}

pub struct FLOATEventMetadata {
  pub let claimable: Bool
  pub let dateCreated: UFix64
  pub let description: String 
  pub let eventId: UInt64
  pub let extraMetadata: {String: AnyStruct}
  pub let groups: [String]
  pub let host: Address
  pub let image: String 
  pub let name: String
  pub let totalSupply: UInt64
  pub let transferrable: Bool
  pub let url: String
  pub let verifiers: [String]
  pub let eventType: String
  pub let price: UFix64?

  init(_ event: &FLOAT.FLOATEvent{FLOAT.FLOATEventPublic}) {
      self.claimable = event.claimable
      self.dateCreated = event.dateCreated
      self.description = event.description
      self.eventId = event.eventId
      self.extraMetadata = event.getExtraMetadata()
      self.groups = event.getGroups()
      self.host = event.host
      self.image = "https://nftstorage.link/ipfs/".concat(event.image)
      self.name = event.name
      self.transferrable = event.transferrable
      self.totalSupply = event.totalSupply
      self.url = event.url
      self.verifiers = event.getVerifiers().keys
      self.eventType = "other"

      if let prices = event.getPrices() {
        let flowTokenVaultIdentifier = Type<@FlowToken.Vault>().identifier
        self.price = prices[flowTokenVaultIdentifier]?.price
      } else {
        self.price = nil
      }
  }
}