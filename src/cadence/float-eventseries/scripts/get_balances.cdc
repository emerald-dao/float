import FungibleToken from "../../core-contracts/FungibleToken.cdc"

pub struct TokenBalance {
  pub let identifier: String
  pub let path: String
  pub let balance: UFix64

  init(
    _ identifier: String,
    _ path: String,
    _ balance: UFix64,
  ) {
    self.identifier = identifier
    self.path = path
    self.balance = balance
  }
}

pub fun main(
  accountAddr: Address,
  balancePaths: [String]
): [TokenBalance] {
  let acct = getAccount(accountAddr)

  let ret: [TokenBalance] = []

  for path in balancePaths {
    let publicPath = PublicPath(identifier: path) ?? panic("Invalid publicPath: ".concat(path))
    if let balanceRef = acct.getCapability<&{FungibleToken.Balance}>(publicPath).borrow() {
      ret.append(TokenBalance(
        balanceRef.getType().identifier,
        path,
        balanceRef.balance
      ))
    }
  }
  return ret
}