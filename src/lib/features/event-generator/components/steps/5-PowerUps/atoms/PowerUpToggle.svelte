<script lang="ts">
	import { eventGeneratorData } from '$lib/features/event-generator/stores/EventGeneratorData';
	import type { PowerUpType } from '$lib/features/event-generator/types/event-generator-data.interface';
	import Icon from '@iconify/svelte';

	export let name: string;
	export let type: PowerUpType;
	export let icon: string;

	$: active = $eventGeneratorData.powerups[type].active === true;
</script>

<span on:click class="row-2 align-center" class:active>
	<Icon {icon} />
	{name}
</span>

<style lang="scss">
	span {
		background-color: var(--clr-neutral-badge);
		border: 1px solid var(--clr-border-primary);
		width: fit-content;
		padding: var(--space-1) var(--space-3);
		border-radius: var(--radius-3);
		cursor: pointer;

		&.active {
			background-color: var(--clr-tertiary-badge);
			color: var(--clr-tertiary-main);
			border-color: var(--clr-tertiary-main);
		}
	}
</style>
