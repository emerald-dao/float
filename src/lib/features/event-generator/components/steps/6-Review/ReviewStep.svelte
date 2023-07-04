<script lang="ts">
	import StepComponentWrapper from '../../atoms/StepComponentWrapper.svelte';
	import { eventGeneratorData } from '$lib/features/event-generator/stores/EventGeneratorData';

	export let stepDataValid = true;

	let activePowerUps: Record<string, any>[] = [];

	function getActivePowerUps(powerups: Record<string, any>): Record<string, any> {
		for (const key in powerups) {
			if (powerups[key].active === true) {
				activePowerUps.push({ [key]: powerups[key] });
			}
		}
		return activePowerUps;
	}

	getActivePowerUps($eventGeneratorData.powerups);
</script>

<StepComponentWrapper>
	<div class="col-6">
		<div class="row-4">
			<h5>Claimable</h5>
			<span>{$eventGeneratorData.claimable}</span>
		</div>
		<div class="row-4">
			<h5>Transferrable</h5>
			<span>{$eventGeneratorData.transferrable}</span>
		</div>
		<div class="row-4">
			<h5>Power Ups</h5>
			<div class="col-10">
				{#each activePowerUps as powerUp, i}
					{#each Object.entries(powerUp) as [key, value]}
						{#if key === 'timelock'}
							<div class="row-2">
								<span>{key}</span>
								<div class="col-5">
									<span>start: {value.data.startDate}</span>
									<span>end: {value.data.endDate}</span>
								</div>
							</div>
						{:else}
							<div class="row-2">
								<span>{key}</span>
								<span>{value.data}</span>
							</div>
						{/if}
					{/each}
				{/each}
			</div>
		</div>
	</div>
</StepComponentWrapper>

<style lang="scss">
	.row-4 {
		display: flex;
		justify-content: space-between;
		span {
			display: flex;
			align-items: center;
			justify-content: center;
			width: 100%;
		}
	}

	.col-10 {
		display: flex;
		flex-direction: column;
		justify-content: center;
		align-items: center;
		gap: var(--space-5);
	}
</style>
