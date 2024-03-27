access(all) contract FIND {
  /// lookup if an address has a .find name, if it does pick either the default one or the first registered
	access(all) fun reverseLookup(_ address:Address): String? {
    return "jacob"
	}

  /// Lookup the profile registered for a name
	access(all) fun lookup(_ input:String): Test? {
		return Test("https://i.imgur.com/h1CnQUe.png")
	}

  access(all) struct Test {
    access(all) let avatar: String 

    access(all) fun getAvatar(): String {
      return self.avatar
    }

    init(_ a: String) {
      self.avatar = a
    }
  }
}