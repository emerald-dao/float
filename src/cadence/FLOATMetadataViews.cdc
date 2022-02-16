pub contract FLOATMetadataViews {

    pub struct FLOATMetadataView {
        pub let id: UInt64
        // The unix time this FLOAT was receieved by the ORIGINAL recipient
        pub let dateReceived: UFix64
        // The ID of the event this FLOAT is from.
        pub let eventId: UInt64
        // The address of the host who created the event this
        // FLOAT came from.
        pub let eventHost: Address
        // The original recipient
        pub let originalRecipient: Address
        pub let owner: Address
        // The serial # of this FLOAT (incremented from 0
        // per FLOATEvent)
        pub let serial: UInt64

        // All the metadata associated with the event this FLOAT came from.
        pub let eventMetadata: FLOATEventMetadataView?

        init(
            _id: UInt64,
            _dateReceived: UFix64, 
            _eventId: UInt64,
            _eventHost: Address, 
            _originalRecipient: Address, 
            _owner: Address,
            _serial: UInt64,
            _eventMetadata: FLOATEventMetadataView?
        ) {
            self.id = _id
            self.dateReceived = _dateReceived
            self.eventId = _eventId
            self.eventHost = _eventHost
            self.originalRecipient = _originalRecipient
            self.owner = _owner
            self.serial = _serial
            self.eventMetadata = _eventMetadata
        }
    }

    pub struct FLOATEventMetadataView {
        pub let claimable: Bool
        pub let dateCreated: UFix64
        pub let description: String 
        pub let extraMetadata: {String: String}
        pub let host: Address
        pub let id: UInt64
        pub let image: String 
        pub let name: String
        pub var totalSupply: UInt64
        pub let url: String

        // Event options
        pub let capacity: UInt64?
        pub let startTime: UFix64?
        pub let endTime: UFix64?
        pub let requiresSecret: Bool
        pub let transferrable: Bool
        
        pub let isOpen: Bool

        init(
            _claimable: Bool,
            _capacity: UInt64?,
            _dateCreated: UFix64,
            _description: String, 
            _endTime: UFix64?,
            _extraMetadata: {String: String},
            _host: Address, 
            _id: UInt64,
            _image: String, 
            _isOpen: Bool,
            _name: String,
            _requiresSecret: Bool,
            _startTime: UFix64?,
            _totalSupply: UInt64,
            _transferrable: Bool,
            _url: String
        ) {
            self.claimable = _claimable
            self.dateCreated = _dateCreated
            self.description = _description
            self.extraMetadata = _extraMetadata
            self.host = _host
            self.id = _id
            self.image = _image
            self.name = _name
            self.totalSupply = _totalSupply
            self.url = _url

            self.capacity = _capacity
            self.startTime = _startTime
            self.endTime = _endTime
            self.requiresSecret = _requiresSecret
            self.transferrable = _transferrable
            self.isOpen = _isOpen
        }
    }

    pub struct FLOATEventClaimed {
        pub let id: UInt64
        pub let host: Address
        pub let claimed: {Address: Identifier}

        init(_id: UInt64, _host: Address, _claimed: {Address: Identifier}) {
            self.id = _id 
            self.host = _host 
            self.claimed = _claimed
        }
    }

    pub struct FLOATEventHolders {
        pub let id: UInt64
        pub let host: Address
        pub let currentHolders: {UInt64: Identifier}

        init(_id: UInt64, _host: Address, _currentHolders: {UInt64: Identifier}) {
            self.id = _id 
            self.host = _host 
            self.currentHolders = _currentHolders
        }
    }

    pub struct Identifier {
        pub let id: UInt64
        pub let serial: UInt64
        pub let address: Address

        init(_id: UInt64, _serial: UInt64, _address: Address) {
            self.id = _id
            self.serial = _serial
            self.address = _address
        }
    }
}