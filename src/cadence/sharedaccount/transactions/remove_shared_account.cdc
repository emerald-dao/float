import SharedAccount from "../SharedAccount.cdc"

transaction(user: Address) {

  let Info: &SharedAccount.Info

  prepare(acct: AuthAccount) {
    self.Info = acct.borrow<&SharedAccount.Info>(from: SharedAccount.InfoStoragePath)
                  ?? panic("Could not borrow the Info from the signer.")
  }

  execute {
    self.Info.removeAccount(account: user)
  }
}
