pub contract FIND {
  /// lookup if an address has a .find name, if it does pick either the default one or the first registered
	pub fun reverseLookup(_ address:Address): String? {
    return "jacob"
	}

  /// Lookup the profile registered for a name
	pub fun lookup(_ input:String): Test? {
		return Test("https://i.imgur.com/h1CnQUe.png")
	}

  pub struct Test {
    pub let avatar: String 

    pub fun getAvatar(): String {
      return self.avatar
    }

    init(_ a: String) {
      self.avatar = a
    }
  }
}