<script type="ts">
	import Blur from '$lib/components/Blur.svelte';
	import FloatTicket from '$lib/components/floats/FloatTicket.svelte';
	import type { FLOAT } from '$lib/types/float/float.interface';

	export let pinnedFloats: string[];
	export let floats: FLOAT[];
</script>

<section class="container">
	<h4>Pinned FLOATs</h4>
	<div>
		<Blur color="tertiary" right="22%" top="30%" />
		<Blur left="22%" bottom="20%" />
		{#each pinnedFloats as floatId}
			{#if floats.find((float) => float.id === floatId)}
				<FloatTicket float={floats.find((float) => float.id === floatId)} />
			{/if}
		{/each}
	</div>
</section>

<style type="scss">
	section {
		position: relative;
		display: flex;
		flex-direction: column;
		gap: var(--space-13);
		align-items: center;

		div {
			display: grid;
			grid-template-columns: repeat(2, 1fr);
			gap: var(--space-11);
		}
	}
</style>
