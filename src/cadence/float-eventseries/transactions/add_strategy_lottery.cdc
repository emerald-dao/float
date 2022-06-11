import MetadataViews from "../../core-contracts/MetadataViews.cdc"
import FLOATEventSeries from "../FLOATEventSeries.cdc"
import FLOATTreasuryStrategies from "../FLOATTreasuryStrategies.cdc"

transaction(
  seriesId: UInt64,
  consumable: Bool,
  threshold: UInt64,
  maxClaimableAmount: UInt64,
  autoStart: Bool,
  treasuryFTs: [String],
  treasuryFTsAmount: [UFix64],
  treasuryNFTs: [String],
  treasuryNFTsAmount: [UInt64],
  hasOpeningEnding: Bool,
  openingEnding: UFix64,
  hasClaimableEnding: Bool,
  claimableEnding: UFix64,
  minimiumValidAmount: UInt64,
) {
  let serieshelf: &FLOATEventSeries.EventSeriesBuilder
  let eventSeries: &FLOATEventSeries.EventSeries{FLOATEventSeries.EventSeriesPublic, FLOATEventSeries.EventSeriesPrivate}

  prepare(acct: AuthAccount) {
    // SETUP Event Series builder resource, link public and private
    if acct.borrow<&FLOATEventSeries.EventSeriesBuilder>(from: FLOATEventSeries.FLOATEventSeriesBuilderStoragePath) == nil {
      acct.save(<- FLOATEventSeries.createEventSeriesBuilder(), to: FLOATEventSeries.FLOATEventSeriesBuilderStoragePath)
      acct.link<&FLOATEventSeries.EventSeriesBuilder{FLOATEventSeries.EventSeriesBuilderPublic, MetadataViews.ResolverCollection}>
          (FLOATEventSeries.FLOATEventSeriesBuilderPublicPath, target: FLOATEventSeries.FLOATEventSeriesBuilderStoragePath)
      acct.link<&FLOATEventSeries.EventSeriesBuilder{FLOATEventSeries.EventSeriesBuilderPrivate}>
          (FLOATEventSeries.FLOATEventSeriesBuilderPrivatePath, target: FLOATEventSeries.FLOATEventSeriesBuilderStoragePath)
    }

    self.serieshelf = acct.borrow<&FLOATEventSeries.EventSeriesBuilder>(from: FLOATEventSeries.FLOATEventSeriesBuilderStoragePath)
      ?? panic("Could not borrow the Event Series builder.")
    
    self.eventSeries = self.serieshelf.borrowEventSeriesPrivate(seriesId: seriesId)
      ?? panic("Could not borrow the event series private.")
  }

  pre {
    threshold > 0: "threshold should be greator then zero"
    treasuryFTs.length == treasuryFTsAmount.length: "Array of treasuryFTs parameters should be with same length"
    treasuryNFTs.length == treasuryNFTsAmount.length: "Array of treasuryFTs parameters should be with same length"
    minimiumValidAmount > 0: "minimiumValidAmount should be greator then zero"
  }

  execute {
    let treasury = self.eventSeries.borrowTreasuryPrivate()

    let oneShareOfClaimableFT: {String: UFix64} = {}
    for i, key in treasuryFTs {
      oneShareOfClaimableFT[key] = treasuryFTsAmount[i]
    }

    let oneShareOfClaimableNFT: {String: UInt64} = {}
    for i, key in treasuryNFTs {
      oneShareOfClaimableNFT[key] = treasuryNFTsAmount[i]
    }

    let params: {String: AnyStruct} = {}
    params["minValid"] = minimiumValidAmount
    if hasOpeningEnding {
      params["openingEnd"] = openingEnding
    }
    if hasClaimableEnding {
      params["claimableEnd"] = claimableEnding
    }

    let controller <- self.serieshelf.createStrategyController(
      consumable: consumable,
      threshold: threshold,
      maxClaimableAmount: maxClaimableAmount,
      oneShareOfClaimableFT: oneShareOfClaimableFT,
      oneShareOfClaimableNFT: oneShareOfClaimableNFT
    )

    let strategy <- FLOATTreasuryStrategies.createStrategy(
        type: FLOATTreasuryStrategies.StrategyType.Lottery,
        controller: <- controller,
        params: params
      ) ?? panic("Failed to create strategy")

    treasury.addStrategy(
      strategy: <- strategy,
      autoStart: autoStart
    )

    log("A strategy have been added to a FLOAT EventSeries.")
  }
}
