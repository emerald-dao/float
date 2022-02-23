pub contract FLOATMetadataViews {
    pub struct TokenIdentifier {
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