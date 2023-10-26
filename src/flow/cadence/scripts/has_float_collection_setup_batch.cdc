import FLOAT from "../FLOAT.cdc"
import NonFungibleToken from "../utility/NonFungibleToken.cdc"

pub fun main(users: [Address]): Result {
  let addressesNotSetup: [Address] = []
  for user in users {
    let setupCorrectly: Bool = getAccount(user).getCapability<&FLOAT.Collection{NonFungibleToken.CollectionPublic}>(FLOAT.FLOATCollectionPublicPath).borrow() != nil
    if !setupCorrectly {
      addressesNotSetup.append(user)
    }
  }
  return Result(addressesNotSetup.length == 0, addressesNotSetup)
}

pub struct Result {
  pub let allPass: Bool
  pub let addressesNotSetup: [Address]

  init(_ ap: Bool, _ ans: [Address]) {
    self.allPass = ap
    self.addressesNotSetup = ans
  }
}