import FLOAT from "../FLOAT.cdc"
import FLOATVerifiers from "../FLOATVerifiers.cdc"
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
  pub let host: Address
  pub let backImage: String?
  pub let image: String 
  pub let name: String
  pub let totalSupply: UInt64
  pub let transferrable: Bool
  pub let url: String
  pub let verifiers: {String: AnyStruct}
  pub let eventType: String
  pub let price: UFix64?
  pub let visibilityMode: String
  pub let multipleClaim: Bool

  init(_ event: &FLOAT.FLOATEvent{FLOAT.FLOATEventPublic}) {
      self.claimable = event.claimable
      self.dateCreated = event.dateCreated
      self.description = event.description
      self.eventId = event.eventId
      let extraMetadata = event.getExtraMetadata()
      self.host = event.host
      if let backImage = FLOAT.extraMetadataToStrOpt(extraMetadata, "backImage") {
        self.backImage = "https://nftstorage.link/ipfs/".concat(backImage)
      } else {
        self.backImage = nil
      }
      self.image = "https://nftstorage.link/ipfs/".concat(event.image)
      self.name = event.name
      self.transferrable = event.transferrable
      self.totalSupply = event.totalSupply
      self.url = event.url
      let verifiers = event.getVerifiers()
      self.verifiers = {}
      if let timelock = verifiers[Type<FLOATVerifiers.Timelock>().identifier] {
        if timelock.length > 0 {
          let castedT = timelock[0] as! FLOATVerifiers.Timelock
          self.verifiers["timelock"] = {
            "type": "timelock",
            "dateStart": castedT.dateStart,
            "dateEnding": castedT.dateEnding
          }
        }
      }
      if let minBalance = verifiers[Type<FLOATVerifiers.MinimumBalance>().identifier] {
        if minBalance.length > 0 {
          let castedM = minBalance[0] as! FLOATVerifiers.MinimumBalance
          self.verifiers["minimumBalance"] = {
            "type": "minimumBalance",
            "amount": castedM.amount
          }
        }
      }
      if let secret = verifiers[Type<FLOATVerifiers.SecretV2>().identifier] {
        if secret.length > 0 {
          let castedS = secret[0] as! FLOATVerifiers.SecretV2
          self.verifiers["secret"] = {
            "type": "secret",
            "secret": castedS.publicKey
          }
        }
      }
      if let limited = verifiers[Type<FLOATVerifiers.Limited>().identifier] {
        if limited.length > 0 {
          let castedL = limited[0] as! FLOATVerifiers.Limited
          self.verifiers["limited"] = {
            "type": "limited",
            "capacity": castedL.capacity
          }
          self.verifiers["limited"] = limited[0]
        }
      }
      if let requireEmail = verifiers[Type<FLOATVerifiers.Email>().identifier] {
        if requireEmail.length > 0 {
          self.verifiers["requireEmail"] = {
            "type": "requireEmail"
          }
        }
      }
      self.eventType = FLOAT.extraMetadataToStrOpt(extraMetadata, "eventType") ?? "other"

      if let prices = event.getPrices() {
        let flowTokenVaultIdentifier = Type<@FlowToken.Vault>().identifier
        self.price = prices[flowTokenVaultIdentifier]?.price
      } else {
        self.price = nil
      }

      self.visibilityMode = FLOAT.extraMetadataToStrOpt(extraMetadata, "visibilityMode") ?? "certificate"
      self.multipleClaim = (extraMetadata["allowMultipleClaim"] as! Bool?) ?? false
  }
}