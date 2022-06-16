
export interface EventSeriesBasics {
  name: string;
  description: string;
  image: string;
}

export interface EventSeriesSlot {
  host: string;
  eventId: number;
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
  emptySlotsRequired: boolean;
}


