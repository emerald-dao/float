import MetadataViews from "../../core-contracts/MetadataViews.cdc"
import FungibleToken from "../../core-contracts/FungibleToken.cdc"
import FLOATEventSeries from "../FLOATEventSeries.cdc"

transaction(
  seriesId: UInt64,
  storagePath: String,
  publicPath: String,
  amount: UFix64
) {
  let serieshelf: &FLOATEventSeries.EventSeriesBuilder
  let eventSeries: &FLOATEventSeries.EventSeries{FLOATEventSeries.EventSeriesPublic, FLOATEventSeries.EventSeriesPrivate}
  let fungibleTokenPublicPath: PublicPath
  let fungibleTokenReciever: &FungibleToken.Vault{FungibleToken.Receiver}

  let fungibleTokenToDeposit: @FungibleToken.Vault

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
    self.fungibleTokenPublicPath = PublicPath(identifier: publicPath) ?? panic("Invalid publicPath: ".concat(publicPath))
    self.fungibleTokenReciever = acct.getCapability(self.fungibleTokenPublicPath)
      .borrow<&FungibleToken.Vault{FungibleToken.Receiver}>()
      ?? panic("Could not borrow the fungible token reciever.")

    // fungible token vault
    let vault = acct.borrow<&FungibleToken.Vault>(
      from: StoragePath(identifier: storagePath) ?? panic("Invalid storagePath: ".concat(storagePath))
    ) ?? panic("Could not borrow the fungible token vault.")
    // token resource
    self.fungibleTokenToDeposit <- vault.withdraw(amount: amount)
  }

  pre {
    amount > 0.0: "amount should be greator then zero"
    self.fungibleTokenToDeposit.getType().identifier == self.fungibleTokenReciever.getType().identifier: "Identifier should be same."
  }

  execute {
    let tokenType = self.fungibleTokenToDeposit.getType()
    // check if fungible token registered
    if FLOATEventSeries.getTokenDefinition(tokenType) == nil {
      self.serieshelf.registerToken(path: self.fungibleTokenPublicPath, isNFT: false)
    }

    let treasury = self.eventSeries.borrowTreasuryPrivate()
    treasury.depositFungibleToken(from: <- self.fungibleTokenToDeposit)

    log("Fungible Tokens have been deposited to a FLOAT EventSeries.")
  }
}
