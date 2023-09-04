import FungibleToken from "../utility/FungibleToken.cdc"

pub fun main(address: Address): Bool {
  return getAccount(address).getCapability(/public/flowTokenBalance).borrow<&{FungibleToken.Balance}>() != nil
}