<script lang="ts">
	import { eventGeneratorData } from '$lib/features/event-generator/stores/EventGeneratorData';
	import type {
		PowerUpData,
		PowerUpType
	} from '$lib/features/event-generator/types/event-generator-data.interface';
	import { getContext } from 'svelte';
	import StepComponentWrapper from '../../atoms/StepComponentWrapper.svelte';
	import PowerUpToggle from './atoms/PowerUpToggle.svelte';
	import POWER_UPS from './powerUps';
	import type { Writable } from 'svelte/store';

	export let stepDataValid = true;

	const activePowerUp: Writable<PowerUpType> = getContext('activePowerUp');

	const handleSelectPowerUp = (powerUpType: PowerUpType) => {
		$activePowerUp = powerUpType;
	};
</script>

<StepComponentWrapper>
	<div>
		{#each POWER_UPS as { type, name, icon }}
			<PowerUpToggle {name} {icon} {type} on:click={() => handleSelectPowerUp(type)} />
		{/each}
	</div>
</StepComponentWrapper>

<style lang="scss">
	div {
		display: flex;
		flex-direction: row;
		flex-wrap: wrap;
		gap: var(--space-4);
	}
</style>
