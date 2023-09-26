import FLOAT from "../FLOAT.cdc"

pub fun main(floats: {Address: [UInt64]}): [FLOATMetadata] {
    var returnVal: [FLOATMetadata] = []
    for address in floats.keys {
        let ids: [UInt64] = floats[address]!
        let floatCollection = getAccount(address).getCapability(FLOAT.FLOATCollectionPublicPath)
                        .borrow<&FLOAT.Collection{FLOAT.CollectionPublic}>()
                        ?? panic("Could not borrow the Collection from the account.")
        for id in ids {
            let nft: &FLOAT.NFT = floatCollection.borrowFLOAT(id: id)!
            let eventId = nft.eventId
            let eventHost = nft.eventHost

            if let event = nft.getEventRef() {
                returnVal.append(FLOATMetadata(nft, event))
            }
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
  pub let extraMetadata: {String: AnyStruct}

  init(_ float: &FLOAT.NFT, _ event: &FLOAT.FLOATEvent{FLOAT.FLOATEventPublic}) {
    self.dateReceived = float.dateReceived
    self.eventDescription = event.description
    self.eventId = event.eventId
    self.eventHost = event.host
    self.eventImage = "https://ipfs.io/ipfs/".concat(event.image)
    self.eventName = event.name
    self.transferrable = event.transferrable
    self.totalSupply = event.totalSupply
    self.originalRecipient = float.originalRecipient
    self.id = float.id
    self.serial = float.serial
    self.eventType = (event.getExtraMetadata()["eventType"] as! String?) ?? "other"
    self.extraMetadata = event.getExtraFloatMetadata(serial: self.serial)
    self.visibilityMode = (event.getSpecificExtraMetadata(key: "visibilityMode") as! String?) ?? "certificate"
  }
}