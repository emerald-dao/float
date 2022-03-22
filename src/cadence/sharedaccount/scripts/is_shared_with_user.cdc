import GrantedAccountAccess from "../GrantedAccountAccess.cdc"

pub fun main(account: Address, user: Address): Bool {
  let infoPublic = getAccount(account).getCapability(GrantedAccountAccess.InfoPublicPath)
                              .borrow<&GrantedAccountAccess.Info{GrantedAccountAccess.InfoPublic}>()
                              ?? panic("Could not borrow the InfoPublic from the account.")
  return infoPublic.isAllowed(account: user) || account == user
}