pub contract FLOATMetadataViews {

    pub struct FLOATMetadataView {
        // The unix time this FLOAT was receieved by the ORIGINAL recipient
        pub let dateReceived: UFix64
        // The ID of the event this FLOAT is from.
        pub let eventId: UInt64
        // The address of the host who created the event this
        // FLOAT came from.
        pub let eventHost: Address
        // The original recipient
        pub let originalRecipient: Address
        // The serial # of this FLOAT (incremented from 0
        // per FLOATEvent)
        pub let serial: UInt64

        // All the metadata associated with the event this FLOAT came from.
        pub let eventMetadata: FLOATEventMetadataView?

        init(
            _dateReceived: UFix64, 
            _eventId: UInt64,
            _eventHost: Address, 
            _originalRecipient: Address, 
            _serial: UInt64,
            _eventMetadata: FLOATEventMetadataView?
        ) {
            self.dateReceived = _dateReceived
            self.eventId = _eventId
            self.eventHost = _eventHost
            self.originalRecipient = _originalRecipient
            self.serial = _serial
            self.eventMetadata = _eventMetadata
        }
    }

    pub struct FLOATEventMetadataView {
        pub let claimed: {Address: UInt64}
        pub let dateCreated: UFix64
        pub let description: String 
        pub let host: Address
        pub let id: UInt64
        pub let image: String 
        pub let name: String
        pub let metadata: {String: String}
        pub var totalSupply: UInt64
        pub let transferrable: Bool
        pub let url: String

        // Event options
        pub let claimable: Bool
        pub let startTime: UFix64?
        pub let endTime: UFix64?
        pub let requiresSecret: Bool
        pub let capacity: UInt64?
        
        pub let isOpen: Bool
        pub let active: Bool

        init(
            _claimable: Bool,
            _id: UInt64,
            _host: Address, 
            _name: String,
            _description: String, 
            _image: String, 
            _url: String,
            _transferrable: Bool,
            _metadata: {String: String},
            _dateCreated: UFix64,
            _totalSupply: UInt64,
            _claimed: {Address: UInt64},
            _startTime: UFix64?,
            _endTime: UFix64?,
            _requiresSecret: Bool,
            _capacity: UInt64?,
            _isOpen: Bool,
            _active: Bool
        ) {
            self.claimable = _claimable
            self.id = _id
            self.host = _host
            self.name = _name
            self.description = _description
            self.image = _image
            self.url = _url
            self.transferrable = _transferrable
            self.metadata = _metadata

            self.dateCreated = _dateCreated
            self.totalSupply = _totalSupply
            self.claimed = _claimed
            self.startTime = _startTime
            self.endTime = _endTime
            self.requiresSecret = _requiresSecret
            self.capacity = _capacity
            self.isOpen = _isOpen
            self.active = _active
        }
    }

    pub struct Identifier {
        pub let id: UInt64
        pub let address: Address

        init(_id: UInt64, _address: Address) {
            self.id = _id
            self.address = _address
        }
    }
}