<script lang="ts">
	import EventPage from '$lib/features/event-page/EventPage.svelte';

	export let data;
</script>

<EventPage event={data.overview} />
