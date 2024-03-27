import "FLOAT"

access(all) fun main(floats: {Address: [UInt64]}): [FLOATMetadata] {
    var returnVal: [FLOATMetadata] = []
    for address in floats.keys {
        let ids: [UInt64] = floats[address]!
        let floatCollection = getAccount(address).capabilities.borrow<&FLOAT.Collection>(FLOAT.FLOATCollectionPublicPath)
                        ?? panic("Could not borrow the Collection from the account.")
        for id in ids {
            let nft: &FLOAT.NFT = floatCollection.borrowFLOAT(id: id)!
            let eventId = nft.eventId
            let eventHost = nft.eventHost

            if let eventRef = nft.getEventRef() {
                returnVal.append(FLOATMetadata(nft, eventRef))
            }
        }
    }

    return returnVal
}

access(all) struct FLOATMetadata {
  access(all) let dateReceived: UFix64
  access(all) let eventDescription: String 
  access(all) let id: UInt64
  access(all) let eventHost: Address
  access(all) let eventImage: String 
  access(all) let eventName: String
  access(all) let totalSupply: UInt64
  access(all) let transferrable: Bool
  access(all) let eventType: String
  access(all) let originalRecipient: Address
  access(all) let eventId: UInt64
  access(all) let serial: UInt64
  access(all) let visibilityMode: String
  access(all) let backImage: String?
  access(all) let extraMetadata: {String: AnyStruct}

  init(_ float: &FLOAT.NFT, _ eventRef: &FLOAT.FLOATEvent) {
    self.dateReceived = float.dateReceived
    self.eventDescription = eventRef.description
    self.eventId = eventRef.eventId
    self.eventHost = eventRef.host
    self.eventImage = "https://nftstorage.link/ipfs/".concat(eventRef.image)
    if let backImage = FLOAT.extraMetadataToStrOpt(eventRef.getExtraMetadata(), "backImage") {
      self.backImage = "https://nftstorage.link/ipfs/".concat(backImage)
    } else {
      self.backImage = nil
    }
    self.eventName = eventRef.name
    self.transferrable = eventRef.transferrable
    self.totalSupply = eventRef.totalSupply
    self.originalRecipient = float.originalRecipient
    self.id = float.id
    self.serial = float.serial
    self.eventType = FLOAT.extraMetadataToStrOpt(eventRef.getExtraMetadata(), "eventType") ?? "other"
    self.extraMetadata = eventRef.getExtraFloatMetadata(serial: self.serial)
    self.visibilityMode = FLOAT.extraMetadataToStrOpt(eventRef.getExtraMetadata(), "visibilityMode") ?? "certificate"
  }
}