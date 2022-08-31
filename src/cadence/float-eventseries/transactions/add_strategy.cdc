import MetadataViews from "../../core-contracts/MetadataViews.cdc"
import FLOATEventSeries from "../FLOATEventSeries.cdc"
import FLOATTreasuryStrategies from "../FLOATTreasuryStrategies.cdc"

transaction(
  seriesId: UInt64,
  consumable: Bool,
  threshold: UInt64,
  autoStart: Bool,
  // State Parameters
  hasPendingEnding: Bool,
  pendingEnding: UFix64,
  hasClaimableEnding: Bool,
  claimableEnding: UFix64,
  hasMinimumValid: Bool,
  minimumValidAmount: UInt64?,
  // Delivery Parameters
  strategyMode: UInt8,
  maxClaimableShares: UInt64,
  deliveryMode: UInt8,
  deliveryTokenIdentifier: String,
  deliveryParam1: UFix64?,
) {
  let seriesBuilder: &FLOATEventSeries.EventSeriesBuilder
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

    self.seriesBuilder = acct.borrow<&FLOATEventSeries.EventSeriesBuilder>(from: FLOATEventSeries.FLOATEventSeriesBuilderStoragePath)
      ?? panic("Could not borrow the Event Series builder.")
    
    self.eventSeries = self.seriesBuilder.borrowEventSeriesPrivate(seriesId: seriesId)
      ?? panic("Could not borrow the event series private.")
  }

  pre {
    threshold > 0: "threshold should be greator then zero"
    maxClaimableShares > 0: "max shares should be greator then zero"
    minimumValidAmount == nil || minimumValidAmount! > 0: "minimumValidAmount should be greator then zero"
  }

  execute {
    let treasury = self.eventSeries.borrowTreasuryPrivate()

    let tokenType = CompositeType(deliveryTokenIdentifier) ?? panic("Invalid type: ".concat(deliveryTokenIdentifier))
    assert(FLOATEventSeries.getTokenDefinition(tokenType) != nil, message: "Unregistered key: ".concat(deliveryTokenIdentifier))
    
    let deliveryType = FLOATEventSeries.StrategyDeliveryType(rawValue: deliveryMode) ?? panic("Invalid deliveryMode.")
    let strategyType = FLOATTreasuryStrategies.StrategyType(rawValue: strategyMode) ?? panic("Invalid strategyMode.")
    
    var delivery: {FLOATEventSeries.StrategyDelivery}? = nil
    switch deliveryType {
      case FLOATEventSeries.StrategyDeliveryType.ftIdenticalAmount:
        assert(deliveryParam1 != nil && deliveryParam1! > 0.0, message: "missing delivery parameter.")
        delivery = FLOATEventSeries.StrategyDeliveryFTWithIdenticalAmount(
          tokenType,
          maxClaimableShares,
          oneShareAmount: deliveryParam1!
        )
        break
      case FLOATEventSeries.StrategyDeliveryType.ftRandomAmount:
        assert(deliveryParam1 != nil && deliveryParam1! > 0.0, message: "missing delivery parameter.")
        delivery = FLOATEventSeries.StrategyDeliveryFTWithRandomAmount(
          tokenType,
          maxClaimableShares,
          totalAmount: deliveryParam1!
        )
        break
      case FLOATEventSeries.StrategyDeliveryType.nft:
        delivery = FLOATEventSeries.StrategyDeliverNFT(
          tokenType,
          maxClaimableShares
        )
        break
    }

    let controller <- self.seriesBuilder.createStrategyController(
      consumable: consumable,
      threshold: threshold,
      delivery: delivery ?? panic("Missing delivery instance."),
    )

    // strategy paramters
    let params: {String: AnyStruct} = {}
    if hasMinimumValid {
      params["minValid"] = minimumValidAmount
    }
    if hasPendingEnding {
      params["openingEnd"] = pendingEnding
    }
    if hasClaimableEnding {
      params["claimableEnd"] = claimableEnding
    }

    let strategy <- FLOATTreasuryStrategies.createStrategy(
        type: strategyType,
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
