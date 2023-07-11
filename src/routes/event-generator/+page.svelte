<script lang="ts">
	import EventGenerator from '$lib/features/event-generator/EventGenerator.svelte';
	import { user } from '$stores/flow/FlowStore';
</script>

{#if $user && $user.addr}
	<EventGenerator />
{:else}
	<span>Connect wallet</span>
{/if}
