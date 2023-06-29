import NonFungibleToken from "../../core-contracts/NonFungibleToken.cdc"
import MetadataViews from "../../core-contracts/MetadataViews.cdc"
import NFTCatalog from "../../core-contracts/NFTCatalog.cdc"
import NFTRetrieval from "../../core-contracts/NFTRetrieval.cdc"

pub fun main(
  acct: Address
): [NFTCollectionInfo] {
  let ret: [NFTCollectionInfo] = []
  // get from catalog
  let catalog = NFTCatalog.getCatalog()
  let account = getAuthAccount(acct)

  for key in catalog.keys {
      let value = catalog[key]!
      let tempPathStr = "tempPathCatalog".concat(key)

      var count: UInt64 = 0
      if let tempPublicPath = PublicPath(identifier: tempPathStr) {
        account.link<&{MetadataViews.ResolverCollection}>(
            tempPublicPath,
            target: value.collectionData.storagePath
        )
        let collectionCap = account.getCapability<&{MetadataViews.ResolverCollection}>(tempPublicPath)
        if !collectionCap.check() {
            continue
        }
        count = NFTRetrieval.getNFTCountFromCap(collectionIdentifier : key, collectionCap : collectionCap)
      }

      if count != 0 {
        ret.append(NFTCollectionInfo(
          key: key,
          nftIdentifier: value.nftType.identifier,
          contractAddress: value.contractAddress,
          contractName: value.contractName,
          publicPath: value.collectionData.publicPath,
          storagePath: value.collectionData.storagePath,
          publicLinkedType: value.collectionData.publicLinkedType,
          display: value.collectionDisplay,
          amount: count
        ))
      }
  }
  return ret
}

pub struct NFTCollectionInfo {
  pub let key: String
  pub let nftIdentifier: String
  pub let contractAddress: Address
  pub let contractName: String
  pub let publicPath: PublicPath
  pub let storagePath: StoragePath
  pub let publicLinkedType: Type
  pub let display: MetadataViews.NFTCollectionDisplay
  pub let amount: UInt64

  init(
    key: String,
    nftIdentifier: String,
    contractAddress: Address,
    contractName: String,
    publicPath: PublicPath,
    storagePath: StoragePath,
    publicLinkedType: Type,
    display: MetadataViews.NFTCollectionDisplay,
    amount: UInt64,
  ) {
    self.key = key
    self.nftIdentifier = nftIdentifier
    self.contractAddress = contractAddress
    self.contractName = contractName
    self.publicPath = publicPath
    self.storagePath = storagePath
    self.publicLinkedType = publicLinkedType
    self.display = display
    self.amount = amount
  }
}
