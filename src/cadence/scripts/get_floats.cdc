import FLOAT from "../FLOAT.cdc"

pub fun main(account: Address): {UFix64: FLOATMetadataView} {
  let floatCollection = getAccount(account).getCapability(FLOAT.FLOATCollectionPublicPath)
                        .borrow<&FLOAT.Collection{FLOAT.CollectionPublic}>()
                        ?? panic("Could not borrow the Collection from the account.")
  let floats = floatCollection.getIDs()
  var returnVal: {UFix64: FLOATMetadataView} = {}
  for id in floats {
    let float = floatCollection.borrowFLOAT(id: id)
    let event = float.getEventMetadata()
    let floatMetadata = FLOATMetadataView(
      _id: float.id, 
      _dateReceived: float.dateReceived, 
      _eventId: float.eventId, 
      _eventImage: float.eventImage,
      _eventHost: float.eventHost, 
      _eventName: float.eventName,
      _originalRecipient: float.originalRecipient, 
      _owner: account, 
      _serial: float.serial,
      _eventMetadata: FLOATEventMetadataView(
        _dateCreated: event?.dateCreated, 
        _description: event?.description,
        _url: event?.url
      )
    )
    returnVal[float.dateReceived] = floatMetadata
  }

  return returnVal
}

pub struct FLOATMetadataView {
  pub let id: UInt64
  pub let dateReceived: UFix64
  pub let eventId: UInt64
  pub let eventImage: String
  pub let eventHost: Address
  pub let eventName: String
  pub let originalRecipient: Address
  pub let owner: Address
  pub let serial: UInt64
  pub let eventMetadata: FLOATEventMetadataView

  init(
      _id: UInt64,
      _dateReceived: UFix64, 
      _eventId: UInt64,
      _eventImage: String,
      _eventHost: Address, 
      _eventName: String,
      _originalRecipient: Address, 
      _owner: Address,
      _serial: UInt64,
      _eventMetadata: FLOATEventMetadataView
  ) {
      self.id = _id
      self.dateReceived = _dateReceived
      self.eventId = _eventId
      self.eventImage = _eventImage
      self.eventHost = _eventHost
      self.eventName = _eventName
      self.originalRecipient = _originalRecipient
      self.owner = _owner
      self.serial = _serial
      self.eventMetadata = _eventMetadata
  }
}

pub struct FLOATEventMetadataView {
    pub let dateCreated: UFix64?
    pub let description: String?
    pub let url: String?

    init(
        _dateCreated: UFix64?,
        _description: String?, 
        _url: String?,
    ) {
        self.dateCreated = _dateCreated
        self.description = _description
        self.url = _url
    }
}