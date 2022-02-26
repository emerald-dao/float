pub contract FLOATMetadataViews {
    pub struct TokenIdentifier {
        pub let id: UInt64
        pub let address: Address
        pub let serial: UInt64

        init(_id: UInt64,  _address: Address, _serial: UInt64) {
            self.id = _id
             self.address = _address
            self.serial = _serial
        }
    }
}