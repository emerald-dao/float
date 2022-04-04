import GrantedAccountAccess from "../GrantedAccountAccess.cdc"

transaction(user: Address) {

  let Info: &GrantedAccountAccess.Info

  prepare(acct: AuthAccount) {
    self.Info = acct.borrow<&GrantedAccountAccess.Info>(from: GrantedAccountAccess.InfoStoragePath)
                  ?? panic("Could not borrow the Info from the signer.")
  }

  execute {
    self.Info.removeAccount(account: user)
  }
}
