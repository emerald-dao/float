import type { LimitedStatus } from '../types/verifiers-status.interface';

export const limitedToStatusObject = (maxSupply: number, floatsClaimed: number): LimitedStatus => {
	if (maxSupply === 0) {
		return null;
	}

	if (maxSupply - floatsClaimed <= 0) {
		return {
			status: 'soldout',
			remainingFloats: 0
		};
	}

	return {
		status: 'available',
		remainingFloats: maxSupply - floatsClaimed
	};
};
