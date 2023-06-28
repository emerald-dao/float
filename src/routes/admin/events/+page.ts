import { getEvents } from '$flow/actions.js';
import { user } from '$stores/flow/FlowStore';
import eventsMock from '../_mock-data/eventsMock.js';
import { get } from 'svelte/store';

export async function load() {
	const events = await getEvents('0x99bd48c8036e2876');
	return {
		events
	};
}
