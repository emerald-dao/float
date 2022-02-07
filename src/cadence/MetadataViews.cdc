pub contract MetadataViews {

    // A Resolver provides access to a set of metadata views.
    //
    // A struct or resource (e.g. an NFT) can implement this interface
    // to provide access to the views that it supports.
    //
    pub resource interface Resolver {
        pub fun getViews(): [Type]
        pub fun resolveView(_ view: Type): AnyStruct?
    }

    // A ResolverCollection is a group of view resolvers index by ID.
    //
    pub resource interface ResolverCollection {
        pub fun borrowViewResolver(id: UInt64): &{Resolver}
        pub fun getIDs(): [UInt64]
    }

    pub struct FLOATMetadataView {
        // The original recipient
        pub let recipient: Address
        // The address of the host who created the event this
        // FLOAT came from.
        pub let host: Address
        // The name of the event this FLOAT came from.
        pub let name: String 
        // The ID of the event this FLOAT is from.
        pub let eventID: UInt64
        pub let description: String
        pub let dateReceived: UFix64
        pub let image: String
        // The serial # of this FLOAT (incremented from 0
        // per FLOATEvent)
        pub let serial: UInt64
        pub let transferrable: Bool

        init(_recipient: Address,  _serial: UInt64, _host: Address, _name: String, _eventID: UInt64, _description: String, _image: String, _transferrable: Bool) {
            self.recipient = _recipient
            self.serial = _serial
            self.host = _host
            self.name = _name
            self.eventID = _eventID
            self.description = _description
            self.dateReceived = getCurrentBlock().timestamp
            self.image = _image
            self.transferrable = _transferrable
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
            _isOpen: Bool
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

    // Display is a basic view that includes the name, description and
    // thumbnail for an object. Most objects should implement this view.
    //
    pub struct Display {

        // The name of the object. 
        //
        // This field will be displayed in lists and therefore should
        // be short an concise.
        //
        pub let name: String

        // A written description of the object. 
        //
        // This field will be displayed in a detailed view of the object,
        // so can be more verbose (e.g. a paragraph instead of a single line).
        //
        pub let description: String

        // A small thumbnail representation of the object.
        //
        // This field should be a web-friendly file (i.e JPEG, PNG)
        // that can be displayed in lists, link previews, etc.
        //
        pub let thumbnail: AnyStruct{File}

        init(
            name: String,
            description: String,
            thumbnail: AnyStruct{File}
        ) {
            self.name = name
            self.description = description
            self.thumbnail = thumbnail
        }
    }

    // File is a generic interface that represents a file stored on or off chain.
    //
    // Files can be used to references images, videos and other media.
    //
    pub struct interface File {
        pub fun uri(): String
    }

    // IPFSThumbnail returns a thumbnail image for an object
    // stored as an image file in IPFS.
    //
    // IPFS images are referenced by their content identifier (CID)
    // rather than a direct URI. A client application can use this CID
    // to find and load the image via an IPFS gateway.
    //
    pub struct IPFSFile: File {

        // CID is the content identifier for this IPFS file.
        //
        // Ref: https://docs.ipfs.io/concepts/content-addressing/
        //
        pub let cid: String

        // Path is an optional path to the file resource in an IPFS directory.
        //
        // This field is only needed if the file is inside a directory.
        //
        // Ref: https://docs.ipfs.io/concepts/file-systems/
        //
        pub let path: String?

        init(cid: String, path: String?) {
            self.cid = cid
            self.path = path
        }

        // This function returns the IPFS native URL for this file.
        //
        // Ref: https://docs.ipfs.io/how-to/address-ipfs-on-web/#native-urls
        //
        pub fun uri(): String {
            if let path = self.path {
                return "ipfs://".concat(self.cid).concat("/").concat(path)
            }
            
            return "ipfs://".concat(self.cid)
        }
    }
}