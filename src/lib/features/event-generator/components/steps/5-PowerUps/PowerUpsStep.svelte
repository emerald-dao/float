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
	<div>
		{#each POWER_UPS as { type, name, icon }}
			<PowerUpToggle
				{name}
				{icon}
				active={$eventGeneratorData.powerups[type] !== undefined}
				on:click={() => handleSelectPowerUp(type)}
			/>
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
