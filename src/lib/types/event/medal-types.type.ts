export const MEDAL_TYPES = ['gold', 'silver', 'bronze', 'participation'] as const;
export type MedalType = (typeof MEDAL_TYPES)[number];
