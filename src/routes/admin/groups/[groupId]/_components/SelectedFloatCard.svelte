<script lang="ts">
	import { fly } from 'svelte/transition';
	import type { FLOAT } from '$lib/types/float/float.interface';
	import { Label } from '@emerald-dao/component-library';
	import Icon from '@iconify/svelte';
	import { createEventDispatcher } from 'svelte';

	export let float: FLOAT;

	const dispatch = createEventDispatcher();
</script>

<div class="row-3 align-center" in:fly={{ x: 50, duration: 500 }}>
	<div class="card row-4 row-space-between">
		<span class="w-medium small">
			{float.eventName}
		</span>
		<Label size="xx-small" hasBorder={false}>#{float.id}</Label>
	</div>
	<button on:click={() => dispatch('delete', float.id)}>
		<Icon icon="tabler:x" width="13px" />
	</button>
</div>

<style lang="scss">
	.card {
		padding: var(--space-4) var(--space-3);
		border-radius: var(--radius-2);
		width: 100%;
	}

	button {
		all: unset;
		cursor: pointer;
	}
</style>
