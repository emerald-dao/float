import FlowToken from 0x1654653399040a61
import FungibleToken from 0xf233dcee88fe0abe

pub fun main(): UFix64 {
  let vault = getAccount(0x84efe65bd9993ff8).getCapability(/public/flowTokenBalance)
                .borrow<&FlowToken.Vault{FungibleToken.Balance}>()!
  return vault.balance
}