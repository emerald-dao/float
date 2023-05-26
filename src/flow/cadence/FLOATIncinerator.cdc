import FLOAT from "./FLOAT.cdc"

pub contract FLOATIncinerator {

  pub let IncineratorStoragePath: StoragePath
  pub let IncineratorPublicPath: PublicPath

  pub var flameStrength: UInt64
  pub var totalIncinerated: UInt64

  pub resource interface IncineratorPublic {
    pub var individualIncinerated: UInt64
    pub var contributedStrength: UInt64
    pub fun getExtraMetadata(): {String: String}
  }

  pub resource Incinerator: IncineratorPublic {
    pub var individualIncinerated: UInt64
    pub var contributedStrength: UInt64
    access(self) var extraMetadata: {String: String}

    pub fun burn(collection: &FLOAT.Collection, ids: [UInt64]) {
      let length = ids.length
      
      for id in ids {
        let float: &FLOAT.NFT = collection.borrowFLOAT(id: id) ?? panic("This FLOAT does not exist.")
        let score = FLOATIncinerator.calculateScore(dateReceived: float.dateReceived, serial: float.serial)
        self.contributedStrength = self.contributedStrength + score
        FLOATIncinerator.flameStrength = FLOATIncinerator.flameStrength + score
        collection.delete(id: id)
      }

      self.individualIncinerated = self.individualIncinerated + UInt64(length)
      FLOATIncinerator.totalIncinerated = FLOATIncinerator.totalIncinerated + UInt64(length)
    }

    pub fun getExtraMetadata(): {String: String} {
      return self.extraMetadata
    }

    init() {
      self.individualIncinerated = 0
      self.contributedStrength = 0
      self.extraMetadata = {}
    }
  }

  pub fun createIncinerator(): @Incinerator {
    return <- create Incinerator()
  }

  pub fun calculateScore(dateReceived: UFix64, serial: UInt64): UInt64 {
    // Serial
    var serialScore: UInt64 = 0
    if (serial < 10) {
      serialScore = 5
    } else if (serial < 100) {
      serialScore = 4
    } else if (serial < 1000) {
      serialScore = 3
    } else if (serial < 10000) {
      serialScore = 2
    } else if (serial < 100000) {
      serialScore = 1
    }

    // Time
    var timeScore: UInt64 = 0
    var difference = getCurrentBlock().timestamp - dateReceived
    if (difference > 31556926.0) { // a year
      timeScore = 5
    } else if (difference > 2629743.0) { // a month
      timeScore = 4
    } else if (difference > 604800.0) { // a week
      timeScore = 3
    } else if (difference > 86400.0) { // a day
      timeScore = 2
    } else if (difference > 3600.0) { // an hour
      timeScore = 1
    }

    return serialScore + timeScore
  }

  init() {
    self.IncineratorStoragePath = /storage/FLOATIncineratorStoragePath
    self.IncineratorPublicPath = /public/FLOATIncineratorPublicPath
    self.totalIncinerated = 0
    self.flameStrength = 0
  }

}