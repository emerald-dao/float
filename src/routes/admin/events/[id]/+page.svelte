<script>
	import Event from './_components/Event.svelte';

	export let data;
</script>

<Event event={data.event} claims={data.eventClaims} />
