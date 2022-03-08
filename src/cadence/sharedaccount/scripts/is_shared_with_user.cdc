import SharedAccount from "../SharedAccount.cdc"

pub fun main(account: Address, user: Address): Bool {
  let infoPublic = getAccount(account).getCapability(SharedAccount.InfoPublicPath)
                              .borrow<&SharedAccount.Info{SharedAccount.InfoPublic}>()
                              ?? panic("Could not borrow the InfoPublic from the account.")
  return infoPublic.isAllowed(account: user) || account == user
}