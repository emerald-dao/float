import claims from '../../_mock-data/floatClaimsMock';
import { getEvent } from '$flow/actions';
import { getVerifiersState } from '$lib/features/verifiers/functions/getVerifiersState';
import { getEventGeneralStatus } from '$lib/features/verifiers/functions/getEventGeneralStatus';
import type { Event, EventWithStatus } from '$lib/types/event/event.interface';

export async function load({ params }) {
	const event = await getEvent('0x99bd48c8036e2876', params.id);

	const getEventWithStatus = (event: Event): EventWithStatus => {
		const verifiersStatus = getVerifiersState(event.verifiers, Number(event.totalSupply));

		const eventWithStatus: EventWithStatus = {
			...event,
			status: {
				verifiersStatus: verifiersStatus,
				generalStatus: getEventGeneralStatus(verifiersStatus, event.claimable)
			}
		};

		return eventWithStatus;
	};

	return {
		event: getEventWithStatus(event),
		eventClaims: claims
	};
}
