import SharedAccount from "../SharedAccount.cdc"

pub fun main(address: Address): [Address] {
  let infoPublic = getAccount(address).getCapability(SharedAccount.InfoPublicPath)
                              .borrow<&SharedAccount.Info{SharedAccount.InfoPublic}>()
                              ?? panic("Could not borrow the InfoPublic from the account.")
  return infoPublic.getAllowed()
}