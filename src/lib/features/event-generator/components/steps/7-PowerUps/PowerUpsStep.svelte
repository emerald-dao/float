<script lang="ts">
	import { powerUpsValidations, type PowerUpGeneratorData } from './powerUps';
	import { POWER_UPS } from './powerUps';
	import type { PowerUpType } from '$lib/features/event-generator/types/event-generator-data.interface';
	import { getContext } from 'svelte';
	import StepComponentWrapper from '../atoms/StepComponentWrapper.svelte';
	import PowerUpToggle from './atoms/PowerUpToggle.svelte';
	import { derived, type Writable } from 'svelte/store';
	import { eventGeneratorData } from '$lib/features/event-generator/stores/EventGeneratorData';

	export let stepDataValid: boolean;

	const activePowerUp: Writable<PowerUpType> = getContext('activePowerUp');

	const handleSelectPowerUp = (powerUpType: PowerUpType) => {
		$activePowerUp = powerUpType;
	};

	const stepDataValidStore = derived(
		[eventGeneratorData, powerUpsValidations],
		([$eventGeneratorData, $powerUpsValidations]) => {
			return Object.entries($powerUpsValidations).every(([key, value]) => {
				return $eventGeneratorData.powerups[key as PowerUpType].active ? value : true;
			});
		}
	);

	$: stepDataValid = $stepDataValidStore;

	let powerUps = Object.entries(POWER_UPS).map(([key, value]) => {
		return {
			...(value as PowerUpGeneratorData),
			type: key as PowerUpType
		};
	});
</script>

<StepComponentWrapper fitContent={true}>
	<div>
		{#each powerUps as { name, icon, type }}
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
