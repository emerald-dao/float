import FLOAT from "../FLOAT.cdc"
import NonFungibleToken from "../../utility/NonFungibleToken.cdc"
import MetadataViews from "../../utility/MetadataViews.cdc"
import GrantedAccountAccess from "../../sharedaccount/GrantedAccountAccess.cdc"

pub fun main(accountAddr: Address): Bool {
  let acct = getAccount(accountAddr)

  if acct.getCapability<&FLOAT.Collection{FLOAT.CollectionPublic}>(FLOAT.FLOATCollectionPublicPath).borrow() == nil {
      return false
  }

  if acct.getCapability<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic}>(FLOAT.FLOATEventsPublicPath).borrow() == nil {
    return false
  }

  if acct.getCapability<&GrantedAccountAccess.Info{GrantedAccountAccess.InfoPublic}>(GrantedAccountAccess.InfoPublicPath).borrow() == nil {
      return false
  }

  return true
}