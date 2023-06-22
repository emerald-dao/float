<script lang="ts">
	import { getContext } from 'svelte';
	import FloatInfo from './_components/FloatInfo.svelte';
	import type { FLOAT } from '$lib/types/float/float.interface';
	import { page } from '$app/stores';

	const floats: FLOAT[] = getContext('floats');

	$: activeFloat = floats.find((float) => float.eventId === $page.params.id);
</script>

{#if activeFloat === undefined}
	<p>Float not found</p>
{:else}
	<FloatInfo float={activeFloat} />
{/if}
