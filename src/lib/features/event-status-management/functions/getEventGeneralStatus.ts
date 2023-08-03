import type { EventGeneralStatus } from '$lib/types/event/event.interface';
import type { VerifiersStatus } from '../types/verifiers-status.interface';

export const getEventGeneralStatus = (
	verifiersStatus: VerifiersStatus,
	claimability: boolean
): EventGeneralStatus => {
	const { timelockStatus, limitedStatus } = verifiersStatus;

	if (timelockStatus !== null) {
		const { status } = timelockStatus;

		if (status === 'expired') {
			return 'expired';
		} else if (status === 'locked') {
			return 'locked';
		}
	}

	if (limitedStatus !== null) {
		const { status } = limitedStatus;

		if (status === 'soldout') {
			return 'soldout';
		}
	}

	if (!claimability) {
		return 'paused';
	}

	return 'available';
};
