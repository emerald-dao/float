<script lang="ts">
	import { user } from '$stores/flow/FlowStore';
	import { getEvents } from '$flow/actions';
	import { setContext } from 'svelte';
	import type { EventWithStatus } from '$lib/types/event/event.interface';
	import createFetchStore from '../_stores/fetchStore';
	import { getEventsWithStatus } from '$lib/features/event-status-management/functions/getEventsWithStatus';

	const eventsWithStatus = createFetchStore<EventWithStatus[]>(
		async () => getEventsWithStatus(await getEvents($user.addr as string)),
		[]
	);

	setContext('events', eventsWithStatus);
</script>

<slot />
