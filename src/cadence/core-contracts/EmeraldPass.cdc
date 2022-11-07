import FungibleToken from "./FungibleToken.cdc"
import FUSD from "./FUSD.cdc"
import FlowToken from "./FlowToken.cdc"

pub contract EmeraldPass {

  access(self) var treasury: ECTreasury
  // Maps the type of a token to its pricing
  access(self) var pricing: {Type: Pricing}

  pub let VaultPublicPath: PublicPath
  pub let VaultStoragePath: StoragePath

  pub event ChangedPricing(newPricing: {UFix64: UFix64})
  pub event Purchased(subscriber: Address, time: UFix64, vaultType: Type)
  pub event Donation(by: Address, to: Address, time: UFix64, vaultType: Type)

  pub struct ECTreasury {
    pub let tokenTypeToVault: {Type: Capability<&{FungibleToken.Receiver}>}

    pub fun getSupportedTokens(): [Type] {
      return self.tokenTypeToVault.keys
    }

    init() {
      let ecAccount: PublicAccount = getAccount(0x8f9e8e0dc951c5b9)
      self.tokenTypeToVault = {
        Type<@FUSD.Vault>(): ecAccount.getCapability<&FUSD.Vault{FungibleToken.Receiver}>(/public/fusdReceiver),
        Type<@FlowToken.Vault>(): ecAccount.getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver)
      }
    }
  }

  pub struct Pricing {
    // examples in $FUSD
    // 2629743.0 (1 month) -> 100
    // 31556926.0 (1 year) -> 1000
    pub let timeToCost: {UFix64: UFix64}

    pub fun getPrice(time: UFix64): UFix64? {
      return self.timeToCost[time]
    }

    init(_ timeToCost: {UFix64: UFix64}) {
      self.timeToCost = timeToCost
    }
  }

  pub resource interface VaultPublic {
    pub var endDate: UFix64
    pub fun purchase(payment: @FungibleToken.Vault, time: UFix64)
    access(account) fun addTime(time: UFix64)
    pub fun isActive(): Bool
  }

  pub resource Vault: VaultPublic {

    pub var endDate: UFix64

    pub fun purchase(payment: @FungibleToken.Vault, time: UFix64) {
      pre {
        EmeraldPass.getPrice(vaultType: payment.getType(), time: time) != nil: "This is not a supported amount of time."
        EmeraldPass.getPrice(vaultType: payment.getType(), time: time)! == payment.balance:
          "The cost is ".concat(EmeraldPass.getPrice(vaultType: payment.getType(), time: time)!.toString()).concat(" but you passed in ").concat(payment.balance.toString()).concat(".")
      }
      let paymentType = payment.getType()
      EmeraldPass.depositToECTreasury(vault: <- payment)
      self.addTime(time: time)
      emit Purchased(subscriber: self.owner!.address, time: time, vaultType: paymentType)
    }

    pub fun isActive(): Bool {
      return getCurrentBlock().timestamp <= self.endDate
    }

    access(account) fun addTime(time: UFix64) {
      // If you're already active, just add more time to the end date.
      // Otherwise, start the subscription now and set the end date.
      if self.isActive() {
        self.endDate = self.endDate + time
      } else {
        self.endDate = getCurrentBlock().timestamp + time
      }
    }

    init() {
      // We take away 1.0 to make sure users can't execute "active" status
      // in the same transaction.
      self.endDate = getCurrentBlock().timestamp - 1.0
    }

  }

  pub fun createVault(): @Vault {
    return <- create Vault()
  }

  pub resource Admin {

    pub fun changePricing(newPricing: {Type: Pricing}) {
      EmeraldPass.pricing = newPricing
    }

    pub fun giveUserTime(user: Address, time: UFix64) {
      let userVault = getAccount(user).getCapability(EmeraldPass.VaultPublicPath)
                      .borrow<&Vault{VaultPublic}>()
                      ?? panic("Ths receiver has not set up a Vault for Emerald Pass yet.")
      userVault.addTime(time: time)
    }
  
  }

  // A public function because, well, ... um ... you can
  // always call this if you want! :D ;) <3
  pub fun depositToECTreasury(vault: @FungibleToken.Vault) {
    pre {
      self.getTreasury()[vault.getType()] != nil: "We have not set up this payment yet."
    }
    self.getTreasury()[vault.getType()]!.borrow()!.deposit(from: <- vault)
  }

  // A function you can call to donate subscription time to someone else
  pub fun donate(nicePerson: Address, to: Address, time: UFix64, payment: @FungibleToken.Vault) {
    let userVault = getAccount(to).getCapability(EmeraldPass.VaultPublicPath)
                      .borrow<&Vault{VaultPublic}>()
                      ?? panic("Ths receiver has not set up a Vault for Emerald Pass yet.")
    let paymentType = payment.getType()
    userVault.purchase(payment: <- payment, time: time)

    emit Donation(by: nicePerson, to: to, time: time, vaultType: paymentType)
  }

  // Checks to see if a user is currently subscribed to Emerald Pass
  pub fun isActive(user: Address): Bool {
    return getAccount(user).getCapability(EmeraldPass.VaultPublicPath).borrow<&Vault{VaultPublic}>()?.isActive() == true
  }

  pub fun getAllPricing(): {Type: Pricing} {
    return self.pricing
  }

  pub fun getPricing(vaultType: Type): Pricing? {
    return self.getAllPricing()[vaultType]
  }

  pub fun getPrice(vaultType: Type, time: UFix64): UFix64? {
    let pricing = self.getPricing(vaultType: vaultType) ?? panic("Emerald Pass does not support this form of payment.")
    return pricing.getPrice(time: time)
  }

  pub fun getTreasury(): {Type: Capability<&{FungibleToken.Receiver}>} {
    return ECTreasury().tokenTypeToVault
  }

  pub fun getUserVault(user: Address): &Vault{VaultPublic}? {
    return getAccount(user).getCapability(EmeraldPass.VaultPublicPath)
            .borrow<&Vault{VaultPublic}>()
  }

  init() {
    self.treasury = ECTreasury()
    self.pricing = {
      Type<@FUSD.Vault>(): Pricing({
        2629743.0: 100.0, // 1 month
        31556926.0: 1000.0 // 1 year
      }),
      Type<@FlowToken.Vault>(): Pricing({
        2629743.0: 100.0, // 1 month
        31556926.0: 1000.0 // 1 year
      })
    }

    self.VaultPublicPath = /public/EmeraldPassv2
    self.VaultStoragePath = /storage/EmeraldPassv2

    self.account.save(<- create Admin(), to: /storage/EmeraldPassAdmin)
  }
  
}
 