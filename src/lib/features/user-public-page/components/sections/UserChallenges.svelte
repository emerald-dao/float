<script type="ts">
	import type { Event } from '$lib/types/event/event.interface';
	import FloatTicket from '$lib/components/floats/FloatTicket.svelte';
	import { generatedNft } from '$lib/features/event-generator/stores/EventGeneratorData';

	export let contentList: Event[];
</script>

<section class="container">
	<div class="content-wrapper">
		{#each contentList as content}
			<FloatTicket float={$generatedNft} />
		{/each}
	</div>
</section>

<style type="scss">
	section {
		display: flex;
		flex-direction: column;
		gap: var(--space-13);
		align-items: center;

		.content-wrapper {
			display: flex;
			flex-direction: column;
			align-items: center;
			gap: var(--space-5);

			@include mq(medium) {
				display: grid;
				grid-template-columns: repeat(2, 1fr);
				gap: var(--space-11);
			}
		}
	}
</style>
