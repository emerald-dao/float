import FLOAT from "../FLOAT.cdc"
import FLOATVerifiers from "../FLOATVerifiers.cdc"

pub fun main(account: Address, eventId: UInt64): FLOATEventMetadataView {
  let floatEventCollection = getAccount(account).getCapability(FLOAT.FLOATEventsPublicPath)
                              .borrow<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic}>()
                              ?? panic("Could not borrow the FLOAT Events Collection from the account.")
  let event = floatEventCollection.borrowPublicEventRef(eventId: eventId)
  return FLOATEventMetadataView(
    _canAttemptClaim: event.verifier.canAttemptClaim(event: event), 
    _claimable: event.claimable, 
    _dateCreated: event.dateCreated, 
    _description: event.description, 
    _extraMetadata: event.getExtraMetadata(), 
    _host: event.host, 
    _eventId: event.eventId, 
    _image: event.image, 
    _name: event.name, 
    _requiresSecret: event.verifier.activatedModules().contains(Type<FLOATVerifiers.Secret>()) || event.verifier.activatedModules().contains(Type<FLOATVerifiers.MultipleSecret>()), 
    _totalSupply: event.totalSupply, 
    _transferrable: event.transferrable, 
    _url: event.url, 
    _verifier: event.verifier
  )
}

pub struct FLOATEventMetadataView {
    pub let canAttemptClaim: Bool
    pub let claimable: Bool
    pub let dateCreated: UFix64
    pub let description: String 
    pub let extraMetadata: {String: String}
    pub let host: Address
    pub let eventId: UInt64
    pub let image: String 
    pub let name: String
    pub let requiresSecret: Bool
    pub var totalSupply: UInt64
    pub let transferrable: Bool
    pub let url: String
    pub let verifier: {FLOAT.IVerifier}

    init(
        _canAttemptClaim: Bool,
        _claimable: Bool,
        _dateCreated: UFix64,
        _description: String, 
        _extraMetadata: {String: String},
        _host: Address, 
        _eventId: UInt64,
        _image: String, 
        _name: String,
        _requiresSecret: Bool,
        _totalSupply: UInt64,
        _transferrable: Bool,
        _url: String,
        _verifier: {FLOAT.IVerifier}
    ) {
        self.canAttemptClaim = _canAttemptClaim
        self.claimable = _claimable
        self.dateCreated = _dateCreated
        self.description = _description
        self.extraMetadata = _extraMetadata
        self.host = _host
        self.eventId = _eventId
        self.image = _image
        self.name = _name
        self.requiresSecret = _requiresSecret
        self.totalSupply = _totalSupply
        self.transferrable = _transferrable
        self.url = _url
        self.verifier = _verifier
    }
}