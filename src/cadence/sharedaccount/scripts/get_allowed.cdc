import GrantedAccountAccess from "../GrantedAccountAccess.cdc"

pub fun main(address: Address): [Address] {
  let infoPublic = getAccount(address).getCapability(GrantedAccountAccess.InfoPublicPath)
                              .borrow<&GrantedAccountAccess.Info{GrantedAccountAccess.InfoPublic}>()
                              ?? panic("Could not borrow the InfoPublic from the account.")
  return infoPublic.getAllowed()
}