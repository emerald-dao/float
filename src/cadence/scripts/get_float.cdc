import FLOAT from "../FLOAT.cdc"

pub fun main(account: Address, id: UInt64): FLOATMetadataView {
  let floatCollection = getAccount(account).getCapability(FLOAT.FLOATCollectionPublicPath)
                        .borrow<&FLOAT.Collection{FLOAT.CollectionPublic}>()
                        ?? panic("Could not borrow the Collection from the account.")
  let float = floatCollection.borrowFLOAT(id: id)
  return FLOATMetadataView(
    _id: float.id, 
    _dateReceived: float.dateReceived, 
    _eventId: float.eventId, 
    _eventHost: float.eventHost, 
    _originalRecipient: float.originalRecipient, 
    _owner: account, 
    _serial: float.serial
  )
}

pub struct FLOATMetadataView {
  pub let id: UInt64
  pub let dateReceived: UFix64
  pub let eventId: UInt64
  pub let eventHost: Address
  pub let originalRecipient: Address
  pub let owner: Address
  pub let serial: UInt64

  init(
      _id: UInt64,
      _dateReceived: UFix64, 
      _eventId: UInt64,
      _eventHost: Address, 
      _originalRecipient: Address, 
      _owner: Address,
      _serial: UInt64,
  ) {
      self.id = _id
      self.dateReceived = _dateReceived
      self.eventId = _eventId
      self.eventHost = _eventHost
      self.originalRecipient = _originalRecipient
      self.owner = _owner
      self.serial = _serial
  }
}