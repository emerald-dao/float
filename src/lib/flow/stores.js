import { writable, get } from 'svelte/store';
import { TokenListProvider, Strategy, ENV } from "flow-native-token-registry";

export const user = writable(null);
export const getUser = get(user);
export const transactionStatus = writable(null);
export const txId = writable(null);
export const transactionInProgress = writable(false);

export const eventCreationInProgress = writable(false);
export const eventCreatedStatus = writable(false);

export const setupAccountInProgress = writable(false);
export const setupAccountStatus = writable(false);

export const floatClaimingInProgress = writable(false);
export const floatClaimedStatus = writable(false);

export const floatDeletionInProgress = writable(false);
export const floatDeletionStatus = writable(false);

export const floatDistributingInProgress = writable(false);
export const floatDistributingStatus = writable(false);

export const floatDistributingManyInProgress = writable(false);
export const floatDistributingManyStatus = writable(false);

export const floatTransferInProgress = writable(false);
export const floatTransferStatus = writable(false);

export const awardFloatInProgress = writable(false);
export const awardFloatStatus = writable(false);

export const addEventToGroupInProgress = writable(false);
export const addEventToGroupStatus = writable(false);

export const removeEventFromGroupInProgress = writable(false);
export const removeEventFromGroupStatus = writable(false);

export const addSharedMinterInProgress = writable(false);
export const addSharedMinterStatus = writable(false);
export const removeSharedMinterInProgress = writable(false);

export const toggleClaimingInProgress = writable(false);
export const toggleTransferringInProgress = writable(false);

export const addGroupInProgress = writable(false);
export const addGroupStatus = writable(false);

export const deleteGroupInProgress = writable(false);
export const deleteGroupStatus = writable(false);

export const deleteEventInProgress = writable(false);
export const deleteEventStatus = writable(false);

export const incinerateInProgress = writable(false);
export const incinerateStatus = writable(false);



/**
____ _  _ ____ _  _ ___    ____ ____ ____ _ ____ ____ 
|___ |  | |___ |\ |  |     [__  |___ |__/ | |___ [__  
|___  \/  |___ | \|  |     ___] |___ |  \ | |___ ___] 
 */

/**
 * @param {string} key 
 */
 const buildWraitable = () => {
  return {
    "InProgress": writable(false),
    "Status": writable(false),
  }
}

/**
 * Event Series Reactive
 */
export const eventSeries = {
  Creation: buildWraitable(),
  AddAchievementGoal: buildWraitable(),
  UpdateBasics: buildWraitable(),
  UpdateSlots: buildWraitable(),
  AddTreasuryStrategy: buildWraitable(),
  TreasuryManegement: buildWraitable(),
  NextTreasuryStrategyStage: buildWraitable(),
  AccompllishGoals: buildWraitable(),
  ClaimTreasuryRewards: buildWraitable(),
}

const tokenList = writable(null);
export const getLatestTokenList = async () => {
  /** @type {import('flow-native-token-registry').TokenInfo[]} */
  const cachedList = get(tokenList);
  if (!cachedList) {
    const tokens = await new TokenListProvider().resolve(Strategy.CDN, import.meta.env.VITE_FLOW_NETWORK ?? ENV.Mainnet);
    const list = tokens.getList()
    tokenList.set(list);
    return list;
  }
  return cachedList
}