import type { EventVerifiers } from '$lib/types/event/event.interface';
import { limitedToStatusObject } from './limitedToStatusObject';
import { timelockToStatusObject } from './timelockToStatusObject';
import type {
	LimitedStatus,
	TimelockStatus,
	VerifiersStatus
} from '../../types/verifiers-status.interface';

export const getVerifiersState = (
	verifiers: EventVerifiers,
	floatsClaimed: number
): VerifiersStatus => {
	let timelockVerifier = verifiers['timelock'];
	let limitedVerifier = verifiers['limited'];

	let timelockStatus: TimelockStatus | null = null;
	let limitedStatus: LimitedStatus | null = null;

	if (timelockVerifier) {
		const { dateStart, dateEnding } = timelockVerifier;

		timelockStatus = timelockToStatusObject(dateStart, dateEnding);
	}

	if (limitedVerifier) {
		const { capacity } = limitedVerifier;

		limitedStatus = limitedToStatusObject(Number(capacity), Number(floatsClaimed));
	}

	return {
		timelockStatus: timelockStatus,
		limitedStatus: limitedStatus
	};
};
