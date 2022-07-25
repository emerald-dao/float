
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

export interface EventSeriesSlot {
  host: string;
  eventId: string;
  required?: boolean;
}

export interface EventSeriesIdentifier {
  host: string;
  id: number;
}

export interface EventSeriesData {
  // data memeber
  identifier: EventSeriesIdentifier;
  basics: EventSeriesBasics;
  slots: EventSeriesSlot[];
  // display member
  owner?: string
}

export interface EventSeriesCreateRequest {
  basics: EventSeriesBasics;
  presetEvents: EventSeriesSlot[];
  emptySlotsAmt: number;
  emptySlotsAmtRequired: number;
}


