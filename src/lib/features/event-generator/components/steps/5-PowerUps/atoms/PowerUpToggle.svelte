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

<span
	on:click
	class="row-2 align-center w-medium"
	class:active
	class:selected
	class:shadow-medium={selected}
>
	<Icon {icon} />
	{name}
</span>

<style lang="scss">
	span {
		width: fit-content;
		padding: var(--space-2) var(--space-5);
		border-radius: var(--radius-3);
		cursor: pointer;
		border: 1px solid var(--clr-border-primary);
		transition: 0.4s;
		opacity: 0.6;

		&.active {
			background-color: var(--clr-primary-badge);
			color: var(--clr-primary-main);
			// border-color: var(--clr-primary-main);
		}

		&.selected {
			background-color: var(--clr-surface-secondary);
			border-color: var(--clr-border-primary);
			opacity: 1;
		}

		&.active.selected {
			background-color: var(--clr-primary-badge);
			border-color: var(--clr-primary-main);
		}
	}
</style>
