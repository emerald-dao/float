const REGEXP_IMPORT = /(\s*import\s*)([\w\d]+)(\s+from\s*)([\w\d"-.\\/]+)/g;

/**
 * Returns Cadence template code with replaced import addresses
 * @param {string} code - Cadence template code.
 * @param {{string:string}} [addressMap={}] - name/address map or function to use as lookup table
 * for addresses in import statements.
 * @param byName - lag to indicate whether we shall use names of the contracts.
 * @returns {string}
 */
export const replaceImportAddresses = (code, addressMap, byName = true) => {
  return code.replace(REGEXP_IMPORT, (match, imp, contract, _, address) => {
    const key = byName ? contract : address;
    const newAddress = addressMap instanceof Function ? addressMap(key) : addressMap[key];

    // If the address is not inside addressMap we shall not alter import statement
    const validAddress = newAddress || address;
    return `${imp}${contract} from ${validAddress}`;
  });
};

/**
____ _  _ ____ _  _ ___
|___ |  | |___ |\ |  | 
|___  \/  |___ | \|  | 
 */

export { default as txCreateEvent } from '../../cadence/float/transactions/create_event.cdc?raw'

/**
____ _  _ ____ _  _ ___    ____ ____ ____ _ ____ ____ 
|___ |  | |___ |\ |  |     [__  |___ |__/ | |___ [__  
|___  \/  |___ | \|  |     ___] |___ |  \ | |___ ___] 
 */

// Contants
export const STRATEGY_RAFFLE = 'raffleStrategy'
export const STRATEGY_QUEUE = 'queueStrategy'

export const DELIVERY_FT_IDENTICAL = 'ftIdenticalAmount'
export const DELIVERY_FT_RANDOM = 'ftRandomAmount'
export const DELIVERY_NFT = 'nft'

// -------------- Setter - Transactions --------------
// ** Event Series Builder **
export { default as txCreateEventSeries } from '../../cadence/float-eventseries/transactions/create_eventseries.cdc?raw'
export { default as txRevokeEventSeries } from '../../cadence/float-eventseries/transactions/revoke_event_series.cdc?raw'
export { default as txUpdateEventSeriesBasics } from '../../cadence/float-eventseries/transactions/update_eventseries_basics.cdc?raw'
export { default as txUpdateEventSeriesSlots } from '../../cadence/float-eventseries/transactions/update_eventseries_slots.cdc?raw'
export { default as txAddEventSeriesGoalByAmount } from '../../cadence/float-eventseries/transactions/add_achievement_goal_by_amount.cdc?raw'
export { default as txAddEventSeriesGoalByPercent } from '../../cadence/float-eventseries/transactions/add_achievement_goal_by_percent.cdc?raw'
export { default as txAddEventSeriesGoalBySpecifics } from '../../cadence/float-eventseries/transactions/add_achievement_goal_by_specifics.cdc?raw'
export { default as txAddTreasuryStrategy } from '../../cadence/float-eventseries/transactions/add_strategy.cdc?raw'
export { default as txDepositFungibleTokenToTreasury } from '../../cadence/float-eventseries/transactions/deposit_ft.cdc?raw'
export { default as txDepositNonFungibleTokenToTreasury } from '../../cadence/float-eventseries/transactions/deposit_nft.cdc?raw'
export { default as txNextTreasuryStrategyStage } from '../../cadence/float-eventseries/transactions/next_strategy_stage.cdc?raw'
export { default as txDropTreasury } from '../../cadence/float-eventseries/transactions/drop_treasury.cdc?raw'
// ** Events Collector **
export { default as txAccomplishGoal } from '../../cadence/float-eventseries/transactions/accomplish_goals.cdc?raw'
export { default as txClaimTreasuryRewards } from '../../cadence/float-eventseries/transactions/claim_rewards_treasury.cdc?raw'
export { default as txRefreshUserStrategiesStatus } from '../../cadence/float-eventseries/transactions/refresh_user_strategies_status.cdc?raw'
// For Dev
export { default as txCleanup } from '../../cadence/float-eventseries/transactions/dev/cleanup.cdc?raw'

// -------------- Getter - Scripts --------------
// ** Event Series Builder **
export { default as scGetEventSeriesGoals } from '../../cadence/float-eventseries/scripts/get_series_goals.cdc?raw'

// ** Events Collector **
export { default as scGetGlobalEventSeriesList } from '../../cadence/float-eventseries/scripts/get_global_event_series_list.cdc?raw'
export { default as scGetEventSeriesList } from '../../cadence/float-eventseries/scripts/get_event_series_list.cdc?raw'
export { default as scGetEventSeries } from '../../cadence/float-eventseries/scripts/get_event_series.cdc?raw'

export { default as scGetBalances } from '../../cadence/float-eventseries/scripts/get_balances.cdc?raw'
export { default as scGetCollectionsNotEmpty } from '../../cadence/float-eventseries/scripts/get_collections_not_empty.cdc?raw'
export { default as scGetCollections } from '../../cadence/float-eventseries/scripts/get_collections.cdc?raw'
export { default as scGetTreasuryData } from '../../cadence/float-eventseries/scripts/get_treasury_data.cdc?raw'
export { default as scGetSeriesStrategies } from '../../cadence/float-eventseries/scripts/get_series_strategies.cdc?raw'

export { default as scHasAchievementBoard } from '../../cadence/float-eventseries/scripts/has_achievement_board.cdc?raw'
export { default as scGetAchievementRecords } from '../../cadence/float-eventseries/scripts/get_achievement_records.cdc?raw'
export { default as scGetAndCheckEventSeriesGoals } from '../../cadence/float-eventseries/scripts/get_and_check_series_goals.cdc?raw'
