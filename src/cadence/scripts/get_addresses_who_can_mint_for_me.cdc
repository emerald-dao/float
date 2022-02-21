import FLOAT from "../FLOAT.cdc"

pub fun main(address: Address): [Address] {
  let floatEventCollection = getAccount(address).getCapability(FLOAT.FLOATEventsPublicPath)
                              .borrow<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic}>()
                              ?? panic("Could not borrow the FLOAT Events Collection from the account.")
  return floatEventCollection.getAddressWhoCanMintForMe()
}