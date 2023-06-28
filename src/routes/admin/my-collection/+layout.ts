import { getFLOATs } from '$flow/actions.js';
import { get } from 'svelte/store';
import myCollectionMock from '../_mock-data/myCollectionMock.js';
import { user } from '$stores/flow/FlowStore.js';

export async function load() {
	const floats = await getFLOATs('0x99bd48c8036e2876');
	return {
		floats
	};
}
