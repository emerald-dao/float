<script lang="ts">
	import { getContext, onMount } from 'svelte';
	import FloatInfo from './_components/FloatInfo.svelte';
	import type { FLOAT } from '$lib/types/float/float.interface';
	import { page } from '$app/stores';
	import type { Writable } from 'svelte/store';

	const floats: Writable<FLOAT[]> = getContext('floats');

	$: activeFloat = $floats.find((float) => float.id === $page.params.id);

	onMount(() => {
		activeFloat = $floats[0];
	});
</script>

{#if activeFloat === undefined}
	<div class="center">
		<p class="center">Float not found</p>
	</div>
{:else}
	{#each $floats as float (float.id)}
		{#if float.id === activeFloat.id}
			<FloatInfo {float} />
		{/if}
	{/each}
{/if}
