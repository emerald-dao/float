
export interface PickableEvent {
  picked: boolean
  event: FloatEvent
}

export interface FloatEvent {
  host: string
  eventId: string
  groups: string[]

  image: string
  name: string
  description: string
  url: string

  totalSupply: number
  claimable: boolean
  transferrable: boolean
  dateCreated: number
}

export interface EventSeriesBasics {
  name: string;
  description: string;
  image: string;
}

enum GoalStatus {
  todo = '0',
  ready = '1',
  accomplished = '2',
}

export interface EventSeriesAchievementGoal {
  type: GoalType;
  points: number;
  params?: GoalParamsType
  status?: GoalStatus;
}

interface Identifier {
  host: string;
  id: string;
}

interface EventSeriesSlot {
  event?: Identifier
  required: boolean;
}

export interface EventSeriesData {
  // data memeber
  identifier: Identifier;
  basics: EventSeriesBasics;
  slots: EventSeriesSlot[];
  // calc member
  sequence?: number
  // display member
  owner?: string
}

export interface EventSeriesCreateRequest {
  basics: EventSeriesBasics;
  presetEvents: EventSeriesSlot[];
  emptySlotsAmt: number;
  emptySlotsAmtRequired: number;
}

export type GoalType = 'byAmount' | 'byPercent' | 'bySpecifics'
export type GoalParamsType = ByAmountParams | ByPercentParams | BySpecifics

interface ByAmountParams {
  eventsAmount: number
  requiredEventsAmount: number
}

interface ByPercentParams {
  percent: number
}

interface BySpecifics {
  events: Identifier[]
}

export interface AddAchievementGoalRequest {
  type: GoalType;
  seriesId: string;
  points: number;
  params?: GoalParamsType
}
