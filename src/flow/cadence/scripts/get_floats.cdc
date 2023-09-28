import FLOAT from "../FLOAT.cdc"
pub fun main(account: Address): [FLOATMetadata] {
  let floatCollection = getAccount(account).getCapability(FLOAT.FLOATCollectionPublicPath)
                        .borrow<&FLOAT.Collection{FLOAT.CollectionPublic}>()
                        ?? panic("Could not borrow the Collection from the account.")
  let ids = floatCollection.getIDs()
  var returnVal: [FLOATMetadata] = []
  for id in ids {
    let nft: &FLOAT.NFT = floatCollection.borrowFLOAT(id: id)!
    let eventId = nft.eventId
    let eventHost = nft.eventHost

    if let event = nft.getEventRef() {
      returnVal.append(FLOATMetadata(nft, event))
    }
  }

  return returnVal
}

pub struct FLOATMetadata {
  pub let dateReceived: UFix64
  pub let eventDescription: String 
  pub let id: UInt64
  pub let eventHost: Address
  pub let eventImage: String 
  pub let eventName: String
  pub let totalSupply: UInt64
  pub let transferrable: Bool
  pub let eventType: String
  pub let originalRecipient: Address
  pub let eventId: UInt64
  pub let serial: UInt64
  pub let visibilityMode: String
  pub let backImage: String?
  pub let extraMetadata: {String: AnyStruct}

  init(_ float: &FLOAT.NFT, _ event: &FLOAT.FLOATEvent{FLOAT.FLOATEventPublic}) {
    self.dateReceived = float.dateReceived
    self.eventDescription = event.description
    self.eventId = event.eventId
    self.eventHost = event.host
    self.eventImage = "https://ipfs.io/ipfs/".concat(event.image)
    if let backImage = FLOAT.extraMetadataToStrOpt(event.getExtraMetadata(), "backImage") {
      self.backImage = "https://ipfs.io/ipfs/".concat(backImage)
    } else {
      self.backImage = nil
    }
    self.eventName = event.name
    self.transferrable = event.transferrable
    self.totalSupply = event.totalSupply
    self.eventType = FLOAT.extraMetadataToStrOpt(event.getExtraMetadata(), "eventType") ?? "other"
    self.originalRecipient = float.originalRecipient
    self.id = float.id
    self.serial = float.serial
    self.extraMetadata = event.getExtraFloatMetadata(serial: self.serial)
    self.visibilityMode = FLOAT.extraMetadataToStrOpt(event.getExtraMetadata(), "visibilityMode") ?? "certificate"
  }
}