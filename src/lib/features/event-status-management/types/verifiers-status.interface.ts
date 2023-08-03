export interface VerifiersStatus {
	timelockStatus: TimelockStatus;
	limitedStatus: LimitedStatus;
}

export type TimelockStatus = {
	status: 'locked' | 'unlocked' | 'expired';
	remainingTime: number;
} | null;

export type LimitedStatus = {
	status: 'soldout' | 'available';
	remainingFloats: number;
} | null;
