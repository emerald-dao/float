<script lang="ts">
	import { fly } from 'svelte/transition';
	import { createEventDispatcher } from 'svelte';
	import Icon from '@iconify/svelte';

	export let description: string;

	const dispatch = createEventDispatcher();
</script>

<div class="sidebar-wrapper" transition:fly|local={{ x: 10, duration: 200 }}>
	<div class="button" on:click={() => dispatch('closeModal')} on:keydown>
		<Icon icon="tabler:x" />
	</div>
	<div class="data-wrapper">
		<h4 class="w-medium">About This Event</h4>
		<p class="small">
			{description}
		</p>
	</div>
</div>

<style lang="scss">
	.sidebar-wrapper {
		position: fixed;
		top: 0;
		right: 0;
		height: 100%;
		width: 100%;
		z-index: 1000;
		display: flex;
		flex-direction: column;
		background: var(--clr-surface-primary);
		overflow-y: auto;

		@include mq(medium) {
			width: 35vw;
		}

		.button {
			align-self: flex-end;
			margin: var(--space-5);
			padding: var(--space-2) var(--space-4);
			border-radius: var(--radius-1);
			cursor: pointer;

			p {
				color: var(--clr-tertiary-main);
			}
		}

		.data-wrapper {
			display: flex;
			flex-direction: column;
			margin: var(--space-13);
			gap: var(--space-7);
		}
	}
</style>
