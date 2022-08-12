export interface PickableEvent {
  picked: boolean;
  event: FloatEvent;
}

export interface FloatEvent {
  host: string;
  eventId: string;
  groups: string[];

  image: string;
  name: string;
  description: string;
  url: string;

  totalSupply: number;
  claimable: boolean;
  transferrable: boolean;
  dateCreated: number;
}

export interface EventSeriesBasics {
  name: string;
  description: string;
  image: string;
}

enum GoalStatus {
  todo = "0",
  ready = "1",
  accomplished = "2",
}

export interface EventSeriesAchievementGoal {
  type: GoalType;
  points: number;
  params?: GoalParamsType;
  status?: GoalStatus;
}

export interface EventSeriesUserStatus {
  goals: EventSeriesAchievementGoal[];
  owned: Identifier[];
  totalScore: number;
  consumableScore: number;
}

interface Identifier {
  host: string;
  id: string;
}

interface EventSeriesSlot {
  event?: Identifier;
  required: boolean;
}

export interface EventSeriesData {
  // data memeber
  identifier: Identifier;
  basics: EventSeriesBasics;
  slots: EventSeriesSlot[];
  // calc member
  sequence?: number;
  // display member
  owner?: string;
}

export interface EventSeriesCreateRequest {
  basics: EventSeriesBasics;
  presetEvents: EventSeriesSlot[];
  emptySlotsAmt: number;
  emptySlotsAmtRequired: number;
}

export type GoalType = "byAmount" | "byPercent" | "bySpecifics";
export type GoalParamsType = ByAmountParams | ByPercentParams | BySpecifics;

interface ByAmountParams {
  eventsAmount: number;
  requiredEventsAmount: number;
}

interface ByPercentParams {
  percent: number;
}

interface BySpecifics {
  events: Identifier[];
}

export interface AddAchievementGoalRequest {
  type: GoalType;
  seriesId: string;
  points: number;
  params?: GoalParamsType;
}

export type TreasuryMgrType = "depositFT" | "depositNFT" | "dropAll";

export interface TreasuryManagementRequeset {
  type: TreasuryMgrType;
  seriesId: string;
  storagePath?: string;
  publicPath?: string;
  amount: number;
}

export interface TreasuryData {
  tokenBalances: [{ identifier: string; balance: string }];
  collectionIDs: [{ identifier: string; ids: [string] }];
}

export type StrategyType = "raffleStrategy" | "queueStrategy";
export type DeliveryType = "ftIdenticalAmount" | "ftRandomAmount" | "nft";
export type StategyStatus = "preparing" | "opening" | "claimable" | "closed";

interface AddStrategyOptions {
  // if comsume achievement point
  consumable: boolean;
  // how many achievement points in valid to claim
  threshold: string;
  // auto start strategy
  autoStart: boolean;
  openingEnding?: number;
  claimableEnding?: number;
  minimumValidAmount?: number;
  // Delivery Parameters
  maxClaimableShares: number;
  deliveryTokenIdentifier: string;
  deliveryParam1?: number;
}

export interface AddStrategyRequest {
  seriesId: string;
  strategyMode: StrategyType;
  deliveryMode: DeliveryType;
  options: AddStrategyOptions;
}

interface StrategyDetail {
  index: number;
  strategyMode: StrategyType;
  strategyData: {
    openingEnding?: number;
    claimableEnding?: number;
    // if comsume achievement point
    consumable: boolean;
    // how many achievement points in valid to claim
    threshold: number;
    // how many users is required to go next stage
    minValid?: number;
    valid?: [string];
    winners?: [string];
  };
  deliveryMode: DeliveryType;
  deliveryStatus: {
    deliveryTokenIdentifier: string;
    // status
    maxClaimableShares: number;
    claimedShares: number;
    restAmount: string;
    oneShareAmount?: string;
    totalAmount?: string;
  };
  currentState: StategyStatus;
  userStatus?: {
    eligible: boolean;
    claimable: boolean;
    claimed: boolean;
  };
}

export interface StrategyQueryResult {
  strategies: [StrategyDetail];
  available?: TreasuryData;
  userTotalScore?: number;
  userConsumableScore?: number;
}

export interface TokenBalance {
  balance: string;
  identifier: string;
  path: string;
}

interface PathInfo {
  domain: "public" | "private" | "storage";
  identifier: string;
}

interface CollectionDisplay {
  name: string;
  description: string;
  externalURL: {
    url: string;
  };
  squareImage: {
    file: {
      url: string;
    };
  };
  bannerImage: {
    file: {
      url: string;
    };
  };
  socials: {
    discord?: {
      url: string;
    };
    twitter?: {
      url: string;
    };
    instagram?: {
      url: string;
    };
  };
}

export interface CollectionInfo {
  key: string;
  nftIdentifier: string;
  contractAddress: string;
  contractName: string;
  publicPath: PathInfo;
  storagePath: PathInfo;
  display: CollectionDisplay;
  amount: string;
}
