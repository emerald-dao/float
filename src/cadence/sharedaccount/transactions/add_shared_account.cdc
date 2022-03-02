import SharedAccount from "../SharedAccount.cdc"

transaction (receiver: Address) {

  let Info: &SharedAccount.Info
  
  prepare(acct: AuthAccount) {
    // set up the FLOAT Collection where users will store their FLOATs
    if acct.borrow<&SharedAccount.Info>(from: SharedAccount.InfoStoragePath) == nil {
        acct.save(<- SharedAccount.createInfo(), to: SharedAccount.InfoStoragePath)
        acct.link<&SharedAccount.Info{SharedAccount.InfoPublic}>
                (SharedAccount.InfoPublicPath, target: SharedAccount.InfoStoragePath)
    }

    self.Info = acct.borrow<&SharedAccount.Info>(from: SharedAccount.InfoStoragePath)!
  }

  execute {
    self.Info.addAccount(account: receiver)
  }
}
