import eventMock from '../../_mock-data/oneEventMock';
import claims from '../../_mock-data/floatClaimsMock';
import { getEvent } from '$flow/actions';
import { get } from 'svelte/store';
import { user } from '$stores/flow/FlowStore';

export async function load({ params }) {
	const event = await getEvent(get(user).addr, params.id)
	return {
		event,
		eventClaims: claims
	};
}
