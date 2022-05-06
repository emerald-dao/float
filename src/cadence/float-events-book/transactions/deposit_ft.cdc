import MetadataViews from "../../core-contracts/MetadataViews.cdc"
import FungibleToken from "../../core-contracts/FungibleToken.cdc"
import FLOATEventsBook from "../FLOATEventsBook.cdc"

transaction(
  bookId: UInt64,
  storagePath: String,
  publicPath: String,
  amount: UFix64
) {
  let bookshelf: &FLOATEventsBook.EventsBookshelf
  let eventsBook: &FLOATEventsBook.EventsBook{FLOATEventsBook.EventsBookPublic, FLOATEventsBook.EventsBookPrivate}
  let fungibleTokenPublicPath: PublicPath
  let fungibleTokenReciever: &FungibleToken.Vault{FungibleToken.Receiver}

  let fungibleTokenToDeposit: @FungibleToken.Vault

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
    if FLOATEventsBook.getTokenDefinition(tokenType.identifier) == nil {
      self.bookshelf.registerToken(path: self.fungibleTokenPublicPath, isNFT: false)
    }

    let treasury = self.eventsBook.borrowTreasuryPrivate()
    treasury.depositFungibleToken(from: <- self.fungibleTokenToDeposit)

    log("Fungible Tokens have been deposited to a FLOAT EventsBook.")
  }
}
