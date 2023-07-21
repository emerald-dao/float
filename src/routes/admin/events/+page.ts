import { getEvents } from '$flow/actions.js';
import { datesToStatusObject } from '$lib/utilities/dates/datesToStatusObject.js';
import { user } from '$stores/flow/FlowStore';
import eventsMock from '../_mock-data/eventsMock.js';
import { get } from 'svelte/store';

export async function load() {
	const events = await getEvents('0x99bd48c8036e2876');

	events.forEach((event: Event) => {
		event.verifiers.forEach((verifier) => {
			if (verifier.dateStart && verifier.dateEnding) {
				event.status = datesToStatusObject(verifier.dateStart, verifier.dateEnding);
			}
		});
	});

	return {
		events
	};
}
