import EmeraldPass from "../../core-contracts/EmeraldPass.cdc"

pub fun main(accountAddr: Address): Bool {
  return EmeraldPass.isActive(user: accountAddr)
}