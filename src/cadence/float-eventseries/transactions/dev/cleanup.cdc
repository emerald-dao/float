import FLOATEventSeries from "../../FLOATEventSeries.cdc"

transaction {
  
  prepare(acct: AuthAccount) {
    // SETUP Event Series builder resource, link public and private
    if acct.borrow<&FLOATEventSeries.EventSeriesBuilder>(from: FLOATEventSeries.FLOATEventSeriesBuilderStoragePath) != nil {
      let toBurn <- acct.load<@FLOATEventSeries.EventSeriesBuilder>(from: FLOATEventSeries.FLOATEventSeriesBuilderStoragePath)
      destroy toBurn
    }

    // SETUP Achievement Board resource, link public
    if acct.borrow<&FLOATEventSeries.AchievementBoard>(from: FLOATEventSeries.FLOATAchievementBoardStoragePath) != nil {
      let toBurn <- acct.load<@FLOATEventSeries.AchievementBoard>(from: FLOATEventSeries.FLOATAchievementBoardStoragePath)
      destroy toBurn
    }

    if acct.getCapability<&FLOATEventSeries.EventSeriesBuilder{FLOATEventSeries.EventSeriesBuilderPublic}>(FLOATEventSeries.FLOATEventSeriesBuilderPublicPath) != nil {
      acct.unlink(FLOATEventSeries.FLOATEventSeriesBuilderPublicPath)
    }

    if acct.getCapability<&FLOATEventSeries.EventSeriesBuilder{FLOATEventSeries.EventSeriesBuilderPrivate}>(FLOATEventSeries.FLOATEventSeriesBuilderPrivatePath) != nil {
      acct.unlink(FLOATEventSeries.FLOATEventSeriesBuilderPrivatePath)
    }

    if acct.getCapability<&FLOATEventSeries.AchievementBoard{FLOATEventSeries.AchievementBoardPublic}>(FLOATEventSeries.FLOATAchievementBoardPublicPath) != nil {
      acct.unlink(FLOATEventSeries.FLOATAchievementBoardPublicPath)
    }
  }

  execute {
    log("Done.")
  }
}