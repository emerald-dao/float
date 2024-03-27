import "FungibleToken"

access(all) fun main(address: Address): Bool {
  return getAccount(address).capabilities.borrow<&{FungibleToken.Balance}>(/public/flowTokenBalance) != nil
}