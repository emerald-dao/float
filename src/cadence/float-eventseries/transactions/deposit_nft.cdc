import MetadataViews from "../../core-contracts/MetadataViews.cdc"
import NonFungibleToken from "../../core-contracts/NonFungibleToken.cdc"
import FLOATEventSeries from "../FLOATEventSeries.cdc"

transaction(
  seriesId: UInt64,
  storagePath: String,
  publicPath: String,
  amount: UInt64
) {
  let serieshelf: &FLOATEventSeries.EventSeriesBuilder
  let eventSeries: &FLOATEventSeries.EventSeries{FLOATEventSeries.EventSeriesPublic, FLOATEventSeries.EventSeriesPrivate}
  let nftPublicPath: PublicPath

  let collection: &NonFungibleToken.Collection

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
    
    // event series
    self.eventSeries = self.serieshelf.borrowEventSeriesPrivate(seriesId: seriesId)
      ?? panic("Could not borrow the event series private.")

    // ensure fungible token capability
    self.nftPublicPath = PublicPath(identifier: publicPath) ?? panic("Invalid publicPath: ".concat(publicPath))
    acct.getCapability(self.nftPublicPath)
      .borrow<&{NonFungibleToken.CollectionPublic}>()
      ?? panic("Could not borrow the fungible token reciever.")

    // fungible token vault
    self.collection = acct.borrow<&NonFungibleToken.Collection>(
      from: StoragePath(identifier: storagePath) ?? panic("Invalid storagePath: ".concat(storagePath))
    ) ?? panic("Could not borrow the fungible token vault.")
  }

  pre {
    amount > 0: "amount should be greator then zero"
  }

  execute {
    let allIDs = self.collection.getIDs()
    assert(allIDs.length >= Int(amount), message: "NFT not enought.")

    let tokenType = self.collection.borrowNFT(id: allIDs[0]).getType()
    // check if fungible token registered
    if FLOATEventSeries.getTokenDefinition(tokenType) == nil {
      self.serieshelf.registerToken(path: self.nftPublicPath, isNFT: true)
    }

    // NFTs
    let nftsToDeposit: @[NonFungibleToken.NFT] <- []
    let ids = allIDs.slice(from: 0, upTo: Int(amount))
    for id in ids {
      nftsToDeposit.append(<- self.collection.withdraw(withdrawID: id))
    }

    let treasury = self.eventSeries.borrowTreasuryPrivate()
    treasury.depositNonFungibleTokens(nfts: <- nftsToDeposit)

    log("Non-Fungible Tokens have been deposited to a FLOAT EventSeries.")
  }
}
