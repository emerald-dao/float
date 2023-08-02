import type { VerifiersStatus } from '../types/verifiers-status.interface';

export const isClaimable = (verifiersStatus: VerifiersStatus): boolean => {
	const { timelockStatus, limitedStatus } = verifiersStatus;

	if (timelockStatus !== null) {
		const { status } = timelockStatus;

		if (status !== 'unlocked') {
			return false;
		}
	}

	if (limitedStatus !== null) {
		const { status } = limitedStatus;

		if (status === 'soldout') {
			return false;
		}
	}

	return true;
};
