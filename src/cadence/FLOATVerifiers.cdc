import FLOAT from "./FLOAT.cdc"

pub contract FLOATVerifiers {
    // Example Verifier that is being used for the FLOAT Platform
    pub struct Verifier: FLOAT.IVerifier {
      // They are nil if they are not in effect.
      pub var timelock: Timelock?
      pub var secret: Secret?
      pub var limited: Limited?
      pub var multipleSecret: MultipleSecret?

      pub fun verify(event: &FLOAT.FLOATEvent{FLOAT.FLOATEventPublic}, _ params: {String: AnyStruct}): Bool {
        if let timelock = self.timelock {
          timelock.verify()
        }
        if let secret = self.secret {
          secret.verify(secretPhrase: params["secretPhrase"]! as! String)
        }
        if let limited = self.limited {
          limited.verify(currentCapacity: event.totalSupply)
        }
        if let multipleSecret = self.multipleSecret {
          multipleSecret.verify(secretPhrase: params["secretPhrase"]! as! String)
        }
        return true
      }

      pub fun canAttemptClaim(event: &FLOAT.FLOATEvent{FLOAT.FLOATEventPublic}): Bool {
        var canAttempt: Bool = true
        if let timelock = self.timelock {
          if getCurrentBlock().timestamp < timelock.dateStart || 
              getCurrentBlock().timestamp > timelock.dateEnding {
              canAttempt = false
          }
        }

        if let limited = self.limited {
          if event.totalSupply >= limited.capacity {
              canAttempt = false
          }
        }

        return event.claimable && canAttempt
      }

      pub fun activatedModules(): [Type] {
        let modules: [Type] = []
        if self.timelock != nil {
          modules.append(Type<Timelock>())
        }
        if self.secret != nil {
          modules.append(Type<Secret>())
        }
        if self.limited != nil {
          modules.append(Type<Limited>())
        }
        if self.multipleSecret != nil {
          modules.append(Type<MultipleSecret>())
        }
        return modules
      }

      pub fun getViews(): [Type] {
        let views: [Type] = []
        if self.timelock != nil {
          views.append(Type<Timelock>())
        }
        if self.limited != nil {
          views.append(Type<Limited>())
        }
        return views
      }

      pub fun resolveView(_ view: Type): AnyStruct? {
        switch view {
          case Type<Timelock>():
            return self.timelock
          case Type<Limited>():
            return self.limited
        }
        return nil
      }

      init(_timelock: Bool, _dateStart: UFix64, _timePeriod: UFix64, _limited: Bool, _capacity: UInt64, _secret: Bool, _secrets: [String]) {
        self.timelock = nil
        self.secret = nil
        self.limited = nil
        self.multipleSecret = nil

        if _timelock {
          self.timelock = Timelock(_dateStart: _dateStart, _timePeriod: _timePeriod)
        }
        if _limited {
          self.limited = Limited(_capacity: _capacity)
        }
        if _secret {
          if _secrets.length == 1 {
            self.secret = Secret(_secretPhrase: _secrets[0])
          } else {
            self.multipleSecret = MultipleSecret(_secrets: _secrets)
          }
        }
      }
    }

    // The "modules" to be used by implementing Verifiers
    
    //
    // Timelock
    //
    // Specifies a time range in which the 
    // FLOAT from an event can be claimed
    pub struct Timelock {
        // An automatic switch handled by the contract
        // to stop people from claiming after a certain time.
        pub let dateStart: UFix64
        pub let dateEnding: UFix64

        access(account) fun verify() {
            assert(
                getCurrentBlock().timestamp >= self.dateStart,
                message: "This FLOAT Event has not started yet."
            )
            assert(
                getCurrentBlock().timestamp <= self.dateEnding,
                message: "Sorry! The time has run out to mint this FLOAT."
            )
        }

        init(_dateStart: UFix64, _timePeriod: UFix64) {
            self.dateStart = _dateStart
            self.dateEnding = self.dateStart + _timePeriod
        }
    }

    //
    // Secret
    //
    // Specifies a secret code in order
    // to claim a FLOAT (not very secure, but cool feature)
    pub struct Secret {
        // The secret code, set by the owner of this event.
        pub let secretPhrase: String

        access(account) fun verify(secretPhrase: String) {
            assert(
                self.secretPhrase == secretPhrase, 
                message: "You did not input the correct secret phrase."
            )
        }

        init(_secretPhrase: String) {
            self.secretPhrase = _secretPhrase
        }
    }

    //
    // Limited
    //
    // Specifies a limit for the amount of people
    // who can CLAIM. Not to be confused with how many currently
    // hold a FLOAT from this event, since users can
    // delete their FLOATs.
    pub struct Limited {
        pub var capacity: UInt64

        access(account) fun verify(currentCapacity: UInt64) {
            assert(
                currentCapacity < self.capacity,
                message: "This FLOAT Event is at capacity."
            )
        }

        init(_capacity: UInt64) {
            self.capacity = _capacity
        }
    }

    pub struct MultipleSecret {
        access(account) let secrets: {String: Bool}

        access(account) fun verify(secretPhrase: String) {
            assert(
                self.secrets[secretPhrase] != nil, 
                message: "You did not input a correct secret phrase."
            )
            self.secrets.remove(key: secretPhrase)
        }

        pub fun getSecrets(): {String: Bool} {
          return self.secrets
        }

        init(_secrets: [String]) {
            self.secrets = {}
            for secret in _secrets {
                self.secrets[secret] = true
            }
        }
    }
}