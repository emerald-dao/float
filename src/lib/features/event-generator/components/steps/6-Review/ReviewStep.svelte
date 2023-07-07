<script lang="ts">
	import StepComponentWrapper from '../../atoms/StepComponentWrapper.svelte';
	import { eventGeneratorData } from '$lib/features/event-generator/stores/EventGeneratorData';
	import PowerUpsReview from './powerUpsReview/PowerUpsReview.svelte';

	export let stepDataValid = true;

	let activePowerUps: Record<string, any>[] = [];

	const getActivePowerUps = (powerups: Record<string, any>): Record<string, any> => {
		for (const key in powerups) {
			if (powerups[key].active === true) {
				activePowerUps.push({ [key]: powerups[key] });
			}
		}
		return activePowerUps;
	};

	getActivePowerUps($eventGeneratorData.powerups);
</script>

<StepComponentWrapper>
	<div class="column-6">
		<div>
			<h4 class="w-medium">Basic configurations</h4>
			<p class="small">This configurations can be changed later.</p>
			<div class="content-wrapper">
				<div class="card-primary">
					{#if $eventGeneratorData.claimable}
						FLOAT is claimable
					{:else}
						FLOAT is not claimable
					{/if}
				</div>
				<div class="card-primary">
					{#if $eventGeneratorData.transferrable}
						FLOAT is transferrable
					{:else}
						FLOAT is not transferrable
					{/if}
				</div>
			</div>
		</div>
		<div>
			<h4 class="w-medium">Power Ups</h4>
			<p class="small">This configurations can not changed later.</p>
			<div class="content-wrapper">
				<PowerUpsReview />
			</div>
		</div>
	</div>
</StepComponentWrapper>

<style lang="scss">
	h4 {
		font-size: var(--font-size-4);
		margin-bottom: var(--space-1);
	}

	.content-wrapper {
		margin-top: var(--space-3);
		display: flex;
		flex-direction: row;
		flex-wrap: wrap;
		gap: var(--space-3);
		justify-content: space-between;

		.card-primary {
			padding: var(--space-4);
		}
	}
</style>
