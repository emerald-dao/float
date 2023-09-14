import type { EventVerifier } from '$lib/types/event/event.interface';
import type { Limited, Timelock } from '$lib/types/event/verifiers.interface';
import { limitedToStatusObject } from './limitedToStatusObject';
import { timelockToStatusObject } from './timelockToStatusObject';
import type {
	LimitedStatus,
	TimelockStatus,
	VerifiersStatus
} from '../../types/verifiers-status.interface';

export const getVerifiersState = (
	verifiers: EventVerifier[],
	floatsClaimed: number
): VerifiersStatus => {
	let timelockVerifier: Timelock | null = null;
	let limitedVerifier: Limited | null = null;

	verifiers.forEach((verifier) => {
		if (Object.hasOwn(verifier, 'dateStart') && Object.hasOwn(verifier, 'dateEnding')) {
			timelockVerifier = verifier as Timelock;
		}

		if (Object.hasOwn(verifier, 'capacity')) {
			limitedVerifier = verifier as Limited;
		}
	});

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
