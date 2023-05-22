export const EVENT_TYPES = ['workshop', 'conference', 'hackathon', 'other'] as const;

export type EventType = (typeof EVENT_TYPES)[number];
