import "FLOAT"
import "FLOATVerifiers"
import "FlowToken"

access(all) fun main(account: Address, eventId: UInt64): FLOATEventMetadata {
  let floatEventCollection = getAccount(account).capabilities.borrow<&FLOAT.FLOATEvents>(FLOAT.FLOATEventsPublicPath)
                              ?? panic("Could not borrow the FLOAT Events Collection from the account.")

  let eventRef = floatEventCollection.borrowPublicEventRef(eventId: eventId) ?? panic("This event does not exist in the account")
  let metadata = FLOATEventMetadata(eventRef)
  return metadata
}

access(all) struct FLOATEventMetadata {
  access(all) let claimable: Bool
  access(all) let dateCreated: UFix64
  access(all) let description: String 
  access(all) let eventId: UInt64
  access(all) let host: Address
  access(all) let backImage: String?
  access(all) let image: String 
  access(all) let name: String
  access(all) let totalSupply: UInt64
  access(all) let transferrable: Bool
  access(all) let url: String
  access(all) let verifiers: {String: AnyStruct}
  access(all) let eventType: String
  access(all) let price: UFix64?
  access(all) let visibilityMode: String
  access(all) let multipleClaim: Bool

  init(_ eventRef: &FLOAT.FLOATEvent) {
      self.claimable = eventRef.claimable
      self.dateCreated = eventRef.dateCreated
      self.description = eventRef.description
      self.eventId = eventRef.eventId
      let extraMetadata = eventRef.getExtraMetadata()
      self.host = eventRef.host
      if let backImage = FLOAT.extraMetadataToStrOpt(extraMetadata, "backImage") {
        self.backImage = "https://nftstorage.link/ipfs/".concat(backImage)
      } else {
        self.backImage = nil
      }
      self.image = "https://nftstorage.link/ipfs/".concat(eventRef.image)
      self.name = eventRef.name
      self.transferrable = eventRef.transferrable
      self.totalSupply = eventRef.totalSupply
      self.url = eventRef.url
      let verifiers = eventRef.getVerifiers()
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

      if let prices = eventRef.getPrices() {
        let flowTokenVaultIdentifier = Type<@FlowToken.Vault>().identifier
        self.price = prices[flowTokenVaultIdentifier]?.price
      } else {
        self.price = nil
      }

      self.visibilityMode = FLOAT.extraMetadataToStrOpt(extraMetadata, "visibilityMode") ?? "certificate"
      self.multipleClaim = (extraMetadata["allowMultipleClaim"] as! Bool?) ?? false
  }
}