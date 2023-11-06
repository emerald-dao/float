import FLOAT from "../FLOAT.cdc"
import NonFungibleToken from "../utility/NonFungibleToken.cdc"
import MetadataViews from "../utility/MetadataViews.cdc"
import FlowToken from "../utility/FlowToken.cdc"
import FungibleToken from "../utility/FungibleToken.cdc"

transaction(eventId: UInt64, host: Address, secretSig: String?, emailSig: String?) {
 
  let FLOATEvent: &FLOAT.FLOATEvent{FLOAT.FLOATEventPublic}
  let Collection: &FLOAT.Collection
  let FlowTokenVault: &FlowToken.Vault

  prepare(acct: AuthAccount) {
    // SETUP COLLECTION
    if acct.borrow<&FLOAT.Collection>(from: FLOAT.FLOATCollectionStoragePath) == nil {
        acct.unlink(FLOAT.FLOATCollectionPublicPath)
        acct.save(<- FLOAT.createEmptyCollection(), to: FLOAT.FLOATCollectionStoragePath)
        acct.link<&FLOAT.Collection{NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection, FLOAT.CollectionPublic}>
                (FLOAT.FLOATCollectionPublicPath, target: FLOAT.FLOATCollectionStoragePath)
    }

    // SETUP FLOATEVENTS
    if acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath) == nil {
      acct.unlink(FLOAT.FLOATEventsPublicPath)
      acct.save(<- FLOAT.createEmptyFLOATEventCollection(), to: FLOAT.FLOATEventsStoragePath)
      acct.link<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic, MetadataViews.ResolverCollection}>
                (FLOAT.FLOATEventsPublicPath, target: FLOAT.FLOATEventsStoragePath)
    }

    let FLOATEvents: &FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic} = getAccount(host).getCapability(FLOAT.FLOATEventsPublicPath)
                        .borrow<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic}>()
                        ?? panic("Could not borrow the public FLOATEvents from the host.")
    self.FLOATEvent = FLOATEvents.borrowPublicEventRef(eventId: eventId) ?? panic("This event does not exist.")

    self.Collection = acct.borrow<&FLOAT.Collection>(from: FLOAT.FLOATCollectionStoragePath)
                        ?? panic("Could not get the Collection from the signer.")
    
    self.FlowTokenVault = acct.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)
                            ?? panic("Could not borrow the FlowToken.Vault from the signer.")
  }

  execute {
    let params: {String: AnyStruct} = {}

    // If the FLOAT has a secret phrase on it
    if let unwrappedSecret = secretSig {
      params["secretSig"] = unwrappedSecret
    }
    if let unwrappedEmailSig = emailSig {
      params["emailSig"] = unwrappedEmailSig
    }
 
    // If the FLOAT costs something
    let prices: {String: FLOAT.TokenInfo} = self.FLOATEvent.getPrices() ?? panic("This FLOAT is free.")
    let payment: @FungibleToken.Vault <- self.FlowTokenVault.withdraw(amount: prices[self.FlowTokenVault.getType().identifier]!.price)
    self.FLOATEvent.purchase(recipient: self.Collection, params: params, payment: <- payment)
    log("Purchased the FLOAT.")
  }
}
 