import FLOATEventSeries from "../FLOATEventSeries.cdc"
import NonFungibleToken from "../../core-contracts/NonFungibleToken.cdc"
import FungibleToken from "../../core-contracts/FungibleToken.cdc"
import MetadataViews from "../../core-contracts/MetadataViews.cdc"
import NFTCatalog from "../../core-contracts/NFTCatalog.cdc"
/**
General placeholder for NFT and FT
*/ 
import PLACEHOLDER_CONTRACT from PLACEHOLDER_ADDRESS

transaction(
  host: Address,
  seriesId: UInt64,
  strategyIndex: Int,
) {
  let achievementRecord: &FLOATEventSeries.Achievement
  let eventSeries: &{FLOATEventSeries.EventSeriesPublic}

  prepare(acct: AuthAccount) {
    // SETUP Achievement Board resource, link public
    if acct.borrow<&FLOATEventSeries.AchievementBoard>(from: FLOATEventSeries.FLOATAchievementBoardStoragePath) == nil {
      acct.save(<- FLOATEventSeries.createAchievementBoard(), to: FLOATEventSeries.FLOATAchievementBoardStoragePath)
      acct.link<&FLOATEventSeries.AchievementBoard{FLOATEventSeries.AchievementBoardPublic}>
          (FLOATEventSeries.FLOATAchievementBoardPublicPath, target: FLOATEventSeries.FLOATAchievementBoardStoragePath)
    }

    // get achievement record from signer
    let achievementBoard = acct.borrow<&FLOATEventSeries.AchievementBoard>(from: FLOATEventSeries.FLOATAchievementBoardStoragePath)
      ?? panic("Could not borrow the AchievementBoard from the signer.")
    
    if let record = achievementBoard.borrowAchievementRecordWritable(host: host, seriesId: seriesId) {
      self.achievementRecord = record
    } else {
      achievementBoard.createAchievementRecord(host: host, seriesId: seriesId)
      self.achievementRecord = achievementBoard.borrowAchievementRecordWritable(host: host, seriesId: seriesId)
        ?? panic("Could not borrow the Achievement record")
    }

    // get EventSeries from host
    let builder = getAccount(host)
      .getCapability(FLOATEventSeries.FLOATEventSeriesBuilderPublicPath)
      .borrow<&FLOATEventSeries.EventSeriesBuilder{FLOATEventSeries.EventSeriesBuilderPublic}>()
      ?? panic("Could not borrow the public EventSeriesBuilderPublic.")
    
    self.eventSeries = builder.borrowEventSeriesPublic(seriesId: seriesId)
      ?? panic("Failed to get event series reference.")
    
    let treasury = self.eventSeries.borrowTreasuryPublic()
    // prepare of account resource
    let detail = treasury.getStrategyDetail(strategyIndex: strategyIndex)
    let deliveryTokenType = detail.status.delivery.deliveryTokenType
    if detail.status.delivery.isNFT {
      // ensure collection exists
      let dic = NFTCatalog.getCollectionsForType(nftTypeIdentifier: deliveryTokenType.identifier)
        ?? panic("Failed to find nft collection in nft catalog.")
      assert(dic.keys.length > 0, message: "the nft is regsitered to nft catalog.")
      // get metadata
      let catalogMetadata = NFTCatalog.getCatalogEntry(collectionIdentifier: dic.keys[0])
        ?? panic("Failed to log catalog matadata.")
      let storedType = acct.type(at: catalogMetadata.collectionData.storagePath)
      // ensure nft collection
      if storedType == nil {
        // placeholder for NFT setup
        PLACEHOLDER_NFT_SETUP
      }
    } else {
      let storedType = acct.type(at: PLACEHOLDER_STORAGE_PATH)
      // ensure ft collection
      if storedType == nil {
        // placeholder for FT setup
        PLACEHOLDER_FT_SETUP
      }
    }
  }

  execute {
    let treasury = self.eventSeries.borrowTreasuryPublic()
    // claim reward
    treasury.claim(strategyIndex: strategyIndex, user: self.achievementRecord)

    log("Claimed your rewards from treasury.")
  }
}
