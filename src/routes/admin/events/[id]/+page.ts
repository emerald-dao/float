import eventMock from '../../_mock-data/oneEventMock';
import claims from '../../_mock-data/floatClaimsMock';
import { getEvent } from '$flow/actions';
import { get } from 'svelte/store';
import { user } from '$stores/flow/FlowStore';
import { getFindProfileFromAddressOrName } from '$flow/utils';

export async function load({ params }) {
	const user = getFindProfileFromAddressOrName('0x99bd48c8036e2876');
	const event = await getEvent('0x99bd48c8036e2876', params.id);
	return {
		event,
		user,
		eventClaims: claims
	};
}
