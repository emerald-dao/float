import FLOAT from "../FLOAT.cdc"
import NonFungibleToken from "../core-contracts/NonFungibleToken.cdc"
import MetadataViews from "../core-contracts/MetadataViews.cdc"
import FLOATMetadataViews from "../FLOATMetadataViews.cdc"

transaction(forHost: Address, claimable: Bool, name: String, description: String, image: String, url: String, transferrable: Bool, timelock: Bool, dateStart: UFix64, timePeriod: UFix64, secret: Bool, secrets: [String], limited: Bool, capacity: UInt64) {

  let SharedMinter: &FLOAT.FLOATEvents

  prepare(acct: AuthAccount) {
    let FLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                        ?? panic("Could not borrow the FLOATEvents from the signer.")
    self.SharedMinter = FLOATEvents.getSharedMinterRef(host: forHost) 
                          ?? panic("You do not have access to this host's minting rights.")
  }

  execute {
    let verifier = Verifier(_timelock: timelock, _dateStart: dateStart, _timePeriod: timePeriod, _limited: limited, _capacity: capacity, _secret: secret, _secrets: secrets)
    self.SharedMinter.createEvent(claimable: claimable, description: description, image: image, name: name, transferrable: transferrable, url: url, verifier: verifier, {})
    log("Started a new event for host.")
  }
}  

pub struct Verifier: FLOAT.Verifier {
  // They are nil if they are not in effect.
  pub var timelock: FLOATMetadataViews.Timelock?
  pub var secret: FLOATMetadataViews.Secret?
  pub var limited: FLOATMetadataViews.Limited?
  pub var multipleSecret: FLOATMetadataViews.MultipleSecret?

  pub fun verify(event: &FLOAT.FLOATEvent{FLOAT.FLOATEventPublic}, _ params: {String: AnyStruct}): Bool {
    if let timelock = self.timelock {
      timelock.verify()
    }
    if let secret = self.secret {
      secret.verify(secretPhrase: params["secretPhrase"] as! String)
    }
    if let limited = self.limited {
      limited.verify(currentCapacity: event.totalSupply)
    }
    if let multipleSecret = self.multipleSecret {
      multipleSecret.verify(secretPhrase: params["secretPhrase"] as! String)
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

  pub fun getViews(): [Type] {
    let views: [Type] = []
    if self.timelock != nil {
      views.append(Type<FLOATMetadataViews.Timelock>())
    }
    if self.secret != nil {
      views.append(Type<FLOATMetadataViews.Secret>())
    }
    if self.limited != nil {
      views.append(Type<FLOATMetadataViews.Limited>())
    }
    if self.multipleSecret != nil {
      views.append(Type<FLOATMetadataViews.MultipleSecret>())
    }
    return views
  }

  pub fun resolveView(_ view: Type): AnyStruct? {
    switch view {
      case Type<FLOATMetadataViews.Timelock>():
        return self.timelock
      case Type<FLOATMetadataViews.Secret>():
        return self.secret
      case Type<FLOATMetadataViews.Limited>():
        return self.limited
      case Type<FLOATMetadataViews.MultipleSecret>():
        return self.multipleSecret
      }

    return nil
  }

  init(_timelock: Bool, _dateStart: UFix64, _timePeriod: UFix64, _limited: Bool, _capacity: UInt64, _secret: Bool, _secrets: [String]) {
    self.timelock = nil
    self.secret = nil
    self.limited = nil
    self.multipleSecret = nil

    if _timelock {
      self.timelock = FLOATMetadataViews.Timelock(_dateStart: _dateStart, _timePeriod: _timePeriod)
    }
    if _limited {
      self.limited =  FLOATMetadataViews.Limited(_capacity: _capacity)
    }
    if _secret {
      if _secrets.length == 1 {
        self.secret = FLOATMetadataViews.Secret(_secret: _secrets[0])
      } else {
        self.multipleSecret = FLOATMetadataViews.MultipleSecret(_secrets: _secrets)
      }
    }
  }
}