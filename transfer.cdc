import FlowToken from 0x0ae53cb6e3f42a79
import FungibleToken from 0xee82856bf20e2aa6

transaction(recipient: Address) {
  prepare(signer: AuthAccount) {
    let vault = signer.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)!
    let recipient = getAccount(recipient).getCapability(/public/flowTokenBalance)
                      .borrow<&FlowToken.Vault{FungibleToken.Receiver}>()!
    recipient.deposit(from: <- vault.withdraw(amount: 100.0))
  }
}