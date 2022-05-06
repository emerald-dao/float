import MetadataViews from "../../core-contracts/MetadataViews.cdc"
import FLOATEventsBook from "../FLOATEventsBook.cdc"
import FLOATStrategies from "../FLOATStrategies.cdc"

transaction(
  bookId: UInt64,
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
) {
  let bookshelf: &FLOATEventsBook.EventsBookshelf
  let eventsBook: &FLOATEventsBook.EventsBook{FLOATEventsBook.EventsBookPublic, FLOATEventsBook.EventsBookPrivate}

  prepare(acct: AuthAccount) {
    // SETUP Bookshelf resource, link public and private
    if acct.borrow<&FLOATEventsBook.EventsBookshelf>(from: FLOATEventsBook.FLOATEventsBookshelfStoragePath) == nil {
      acct.save(<- FLOATEventsBook.createEventsBookshelf(), to: FLOATEventsBook.FLOATEventsBookshelfStoragePath)
      acct.link<&FLOATEventsBook.EventsBookshelf{FLOATEventsBook.EventsBookshelfPublic, MetadataViews.ResolverCollection}>
          (FLOATEventsBook.FLOATEventsBookshelfPublicPath, target: FLOATEventsBook.FLOATEventsBookshelfStoragePath)
      acct.link<&FLOATEventsBook.EventsBookshelf{FLOATEventsBook.EventsBookshelfPrivate}>
          (FLOATEventsBook.FLOATEventsBookshelfPrivatePath, target: FLOATEventsBook.FLOATEventsBookshelfStoragePath)
    }

    self.bookshelf = acct.borrow<&FLOATEventsBook.EventsBookshelf>(from: FLOATEventsBook.FLOATEventsBookshelfStoragePath)
      ?? panic("Could not borrow the Bookshelf.")
    
    self.eventsBook = self.bookshelf.borrowEventsBookPrivate(bookId: bookId)
      ?? panic("Could not borrow the events book private.")
  }

  pre {
    threshold > 0: "threshold should be greator then zero"
    treasuryFTs.length == treasuryFTsAmount.length: "Array of treasuryFTs parameters should be with same length"
    treasuryNFTs.length == treasuryNFTsAmount.length: "Array of treasuryFTs parameters should be with same length"
  }

  execute {
    let treasury = self.eventsBook.borrowTreasuryPrivate()

    let oneShareOfClaimableFT: {String: UFix64} = {}
    for i, key in treasuryFTs {
      oneShareOfClaimableFT[key] = treasuryFTsAmount[i]
    }

    let oneShareOfClaimableNFT: {String: UInt64} = {}
    for i, key in treasuryNFTs {
      oneShareOfClaimableNFT[key] = treasuryNFTsAmount[i]
    }

    let params: {String: AnyStruct} = {}
    if hasOpeningEnding {
      params["openingEnd"] = openingEnding
    }
    if hasClaimableEnding {
      params["claimableEnd"] = claimableEnding
    }

    let controller <- self.bookshelf.createStrategyController(
      consumable: consumable,
      threshold: threshold,
      maxClaimableAmount: maxClaimableAmount,
      oneShareOfClaimableFT: oneShareOfClaimableFT,
      oneShareOfClaimableNFT: oneShareOfClaimableNFT
    )

    let strategy <- FLOATStrategies.createStrategy(
        type: FLOATStrategies.StrategyType.ClaimingQueue,
        controller: <- controller,
        params: params
      ) ?? panic("Failed to create strategy")

    treasury.addStrategy(
      strategy: <- strategy,
      autoStart: autoStart
    )

    log("A strategy have been added to a FLOAT EventsBook.")
  }
}
