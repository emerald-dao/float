pub contract SharedAccount {

  pub let InfoStoragePath: StoragePath
  pub let InfoPublicPath: PublicPath

  pub resource interface InfoPublic {
    // Contract Setters
    access(account) fun receiveSharing(account: Address) 
    access(account) fun takeSharing(account: Address)
    // Public Getters
    pub fun getAllowed(): [Address]
    pub fun getCanMintForThem(): [Address]
    pub fun isAllowed(account: Address): Bool
    pub fun canMintFor(account: Address): Bool
  }

  pub resource Info: InfoPublic {
    pub var allowed: {Address: Bool}

    // This is simply for easability. Nothing
    // actually uses this to determine if you
    // can mint for someone or not. This is partially
    // because it's possible for this to be out of
    // sync if someone unlinks their Info from
    // the public domain.
    pub var canMintForThem: {Address: Bool}

    // ACCESSIBLE BY: Owner
    pub fun addAccount(account: Address) {
      // Allow someone to share your account
      self.allowed[account] = true

      let otherAccount = getAccount(account).getCapability(SharedAccount.InfoPublicPath)
                              .borrow<&Info{InfoPublic}>()
                              ?? panic("The person you're allowing must have a set up Info.")
      otherAccount.receiveSharing(account: self.owner!.address)
    }

    // ACCESSIBLE BY: Contract
    access(account) fun receiveSharing(account: Address) {
      self.canMintForThem[account] = true
    }

    // ACCESSIBLE BY: Owner
    pub fun removeAccount(account: Address) {
      self.allowed.remove(key: account)

      // Attempts to remove from the receiver's `canMintForThem`.
      // If you can't, don't panic.
      if let otherAccount = getAccount(account).getCapability(SharedAccount.InfoPublicPath).borrow<&Info{InfoPublic}>() {
        otherAccount.takeSharing(account: self.owner!.address)
      }
    }

    // ACCESSIBLE BY: Owner, Contract
    pub fun takeSharing(account: Address) {
      self.canMintForThem.remove(key: account)
    }

    pub fun getAllowed(): [Address] {
      return self.allowed.keys
    }

    pub fun getCanMintForThem(): [Address] {
      return self.canMintForThem.keys
    }

    pub fun isAllowed(account: Address): Bool {
      return self.allowed.containsKey(account)
    }

    pub fun canMintFor(account: Address): Bool {
      return self.canMintForThem.containsKey(account)
    }

    init() {
      self.allowed = {}
      self.canMintForThem = {}
    }
  }

  pub fun createInfo(): @Info {
    return <- create Info()
  }

  init() {
    self.InfoStoragePath = /storage/SharedAccountInfo002
    self.InfoPublicPath = /public/SharedAccountInfo002
  }

}