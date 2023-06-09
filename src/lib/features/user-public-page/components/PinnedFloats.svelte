<script type="ts">
	import Blur from '$lib/components/Blur.svelte';
	import FloatTicket from '$lib/components/floats/FloatTicket.svelte';
	import { generatedNft } from '$lib/features/event-generator/stores/EventGeneratorData';
</script>

<section class="container">
	<h4>Pinned FLOATs</h4>
	<div>
		<Blur color="tertiary" right="22%" top="30%" />
		<Blur left="22%" bottom="20%" />
		<FloatTicket float={$generatedNft} />
		<FloatTicket float={$generatedNft} />
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
