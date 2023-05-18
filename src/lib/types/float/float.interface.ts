// FLOATs interfaces and types

export interface FLOAT {
  id: string;
  dateReceived: string;
  eventDescription: string;
  eventHost: string;
  eventId: string;
  eventImage: string;
  eventName: string;
  originalRecipient: string;
  serial: string;
  totalSupply: string | null;
  transferrable: boolean;
}
