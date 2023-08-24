<script lang="ts">
	import { Currency } from '@emerald-dao/component-library';
	import Icon from '@iconify/svelte';
	import { createEventDispatcher } from 'svelte';
	import { fly } from 'svelte/transition';

	const dispatch = createEventDispatcher();

	function deleteDist() {
		dispatch('deleteDist');
	}

	export let forAccount: string;
</script>

<div transition:fly|local={{ x: 10, duration: 700 }}>
	<div class="main-wrapper row-4 align-center">
		<div class="card-primary row-space-between align-center">
			<Icon icon="tabler:arrow-narrow-right" />
			<span>{forAccount}</span>
		</div>
		<div class="clickable" on:click={deleteDist} on:keydown>
			<Icon icon="tabler:trash" />
		</div>
	</div>
</div>

<style lang="scss">
	.main-wrapper {
		width: 100%;

		.card-primary {
			width: 100%;
			padding: var(--space-4) var(--space-6);

			span {
				font-size: var(--font-size-0);
			}
		}

		.clickable {
			cursor: pointer;
		}
	}
</style>
