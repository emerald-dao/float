// FLOATs interfaces and types

import type { Limited, MinimumBalance, Secret, Timelock } from "./verifiers.interface";

export interface Event {
  claimable: boolean;
  dateCreated: string;
  description: string;
  eventId: string;
  extraMetadata: { [key: string]: any };
  groups: string[]
  host: string;
  image: string;
  name: string;
  totalSupply: string;
  transferrable: boolean;
  url: string;
  verifiers: EventVerifier[]
}

type EventVerifier =
  | Timelock
  | Secret
  | Limited
  | MinimumBalance