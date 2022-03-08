pub contract SharedAccount {

  pub let InfoStoragePath: StoragePath
  pub let InfoPublicPath: PublicPath

  pub resource interface InfoPublic {
    pub fun getAllowed(): [Address]
    pub fun isAllowed(account: Address): Bool
  }

  pub resource Info: InfoPublic {
    // Nik Will never be in this list
    access(account) var allowed: {Address: Bool}

    // Allow someone to share your account
    pub fun addAccount(account: Address) {
      self.allowed[account] = true
    }

    pub fun removeAccount(account: Address) {
      self.allowed.remove(key: account)
    }

    pub fun getAllowed(): [Address] {
      return self.allowed.keys
    }

    pub fun isAllowed(account: Address): Bool {
      return self.allowed.containsKey(account)
    }

    init() {
      self.allowed = {}
    }
  }

  pub fun createInfo(): @Info {
    return <- create Info()
  }

  init() {
    self.InfoStoragePath = /storage/SharedAccountInfo003
    self.InfoPublicPath = /public/SharedAccountInfo003
  }

}