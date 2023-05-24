<script lang="ts">
	import { eventGeneratorData } from '$lib/features/event-generator/stores/EventGeneratorData';
	import type {
		PowerUpData,
		PowerUps
	} from '$lib/features/event-generator/types/event-generator-data.interface';
	import { getContext } from 'svelte';
	import StepComponentWrapper from '../../atoms/StepComponentWrapper.svelte';
	import PowerUpToggle from './atoms/PowerUpToggle.svelte';
	import POWER_UPS from './powerUps';
	import type { Writable } from 'svelte/store';

	const activePowerUp: Writable<PowerUps> = getContext('activePowerUp');

	const handleSelectPowerUp = (powerUpType: PowerUps) => {
		$activePowerUp = powerUpType;
	};
</script>

<StepComponentWrapper>
	{#each POWER_UPS as { type, name, description }}
		<PowerUpToggle
			{name}
			active={$eventGeneratorData.powerups[type] !== undefined}
			on:click={() => handleSelectPowerUp(type)}
		/>
	{/each}
</StepComponentWrapper>
