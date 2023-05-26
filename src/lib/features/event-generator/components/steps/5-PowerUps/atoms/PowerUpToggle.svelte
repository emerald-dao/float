<script lang="ts">
	import { eventGeneratorData } from '$lib/features/event-generator/stores/EventGeneratorData';
	import type { PowerUpType } from '$lib/features/event-generator/types/event-generator-data.interface';
	import Icon from '@iconify/svelte';
	import { getContext } from 'svelte';
	import type { Writable } from 'svelte/store';

	export let name: string;
	export let type: PowerUpType;
	export let icon: string;

	const activePowerUp: Writable<PowerUpType> = getContext('activePowerUp');

	$: active = $eventGeneratorData.powerups[type].active === true;
	$: selected = $activePowerUp === type;
</script>

<span on:click class="row-2 align-center w-medium" class:active class:selected>
	<Icon {icon} />
	{name}
</span>

<style lang="scss">
	span {
		background-color: var(--clr-neutral-badge);
		width: fit-content;
		padding: var(--space-2) var(--space-5);
		border-radius: var(--radius-3);
		cursor: pointer;
		border: 2px solid transparent;
		transition: 0.2s;

		&.active {
			background-color: var(--clr-primary-badge);
			color: var(--clr-primary-main);
		}

		&.selected {
			border: 2px solid var(--clr-border-primary);
		}
	}
</style>
