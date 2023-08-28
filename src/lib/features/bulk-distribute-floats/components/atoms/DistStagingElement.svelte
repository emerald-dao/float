<script lang="ts">
	import { UserProfileLabel } from '@emerald-dao/component-library';
	import Icon from '@iconify/svelte';
	import { createEventDispatcher } from 'svelte';
	import { fly } from 'svelte/transition';

	const dispatch = createEventDispatcher();

	function deleteDist() {
		dispatch('deleteDist');
	}

	export let forAccount: string;
</script>

<div transition:fly|local={{ x: 10, duration: 300 }}>
	<div class="main-wrapper row-4 align-center">
		<div class="card-primary row-space-between align-center">
			<UserProfileLabel address={forAccount} />
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
			padding: var(--space-3) var(--space-4);
			border-radius: var(--radius-2);
		}

		.clickable {
			cursor: pointer;
		}
	}
</style>
