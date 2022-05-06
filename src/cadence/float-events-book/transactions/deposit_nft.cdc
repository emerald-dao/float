import MetadataViews from "../../core-contracts/MetadataViews.cdc"
import NonFungibleToken from "../../core-contracts/NonFungibleToken.cdc"
import FLOATEventsBook from "../FLOATEventsBook.cdc"

transaction(
  bookId: UInt64,
  storagePath: String,
  publicPath: String,
  ids: [UInt64]
) {
  let bookshelf: &FLOATEventsBook.EventsBookshelf
  let eventsBook: &FLOATEventsBook.EventsBook{FLOATEventsBook.EventsBookPublic, FLOATEventsBook.EventsBookPrivate}
  let nftPublicPath: PublicPath

  let collection: &NonFungibleToken.Collection

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
    
    // events book
    self.eventsBook = self.bookshelf.borrowEventsBookPrivate(bookId: bookId)
      ?? panic("Could not borrow the events book private.")

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
    ids.length > 0: "amount should be greator then zero"
  }

  execute {
    let tokenType = self.collection.borrowNFT(id: ids[0]).getType()
    // check if fungible token registered
    if FLOATEventsBook.getTokenDefinition(tokenType.identifier) == nil {
      self.bookshelf.registerToken(path: self.nftPublicPath, isNFT: true)
    }

    // NFTs
    let nftsToDeposit: @[NonFungibleToken.NFT] <- []
    for id in ids {
      nftsToDeposit.append(<- self.collection.withdraw(withdrawID: id))
    }

    let treasury = self.eventsBook.borrowTreasuryPrivate()
    treasury.depositNonFungibleTokens(nfts: <- nftsToDeposit)

    log("Non-Fungible Tokens have been deposited to a FLOAT EventsBook.")
  }
}
