<script lang="ts">
	import { generatedNft } from './../../../stores/EventGeneratorData';
	import { eventGeneratorActiveStep } from './../../../stores/EventGeneratorSteps';
	import { fly } from 'svelte/transition';
	import StepComponentWrapper from '../../atoms/StepComponentWrapper.svelte';
	import { eventGeneratorData } from '$lib/features/event-generator/stores/EventGeneratorData';
	import PowerUpsReview from './powerUpsReview/PowerUpsReview.svelte';
	import FloatTicket from '$lib/components/floats/FloatTicket.svelte';
	import type { PowerUpType } from '$lib/features/event-generator/types/event-generator-data.interface';

	const hasPowerUps = () => {
		for (const key in $eventGeneratorData.powerups) {
			if ($eventGeneratorData.powerups[key as PowerUpType].active === true) {
				return true;
			}
		}
		return false;
	};
</script>

<StepComponentWrapper alignCenter={true}>
	<div class="main-wrapper">
		<div in:fly|local={{ x: -500, duration: 700 }}>
			<div>
				<FloatTicket float={$generatedNft} showBack={$eventGeneratorActiveStep === 1} />
			</div>
			<div class="target">
				<div id="target-element">
					<FloatTicket
						float={$generatedNft}
						showBack={$eventGeneratorActiveStep === 1}
						isForScreenshot={true}
					/>
				</div>
			</div>
		</div>
		<div class="column-8">
			<div>
				<h4 class="w-medium">Basic configurations</h4>
				<p class="small">Can be changed later.</p>
				<div class="content-wrapper">
					<div class="card">
						<span class="small">
							{#if $eventGeneratorData.claimable}
								FLOAT is claimable
							{:else}
								FLOAT is not claimable
							{/if}
						</span>
					</div>
					<div class="card">
						<span class="small">
							{#if $eventGeneratorData.transferrable}
								FLOAT is transferrable
							{:else}
								FLOAT is not transferrable
							{/if}
						</span>
					</div>
				</div>
			</div>
			{#if hasPowerUps()}
				<div>
					<h4 class="w-medium">+ Power Ups</h4>
					<p class="small">Can not be changed later.</p>
					<div class="content-wrapper">
						<PowerUpsReview />
					</div>
				</div>
			{/if}
		</div>
	</div>
</StepComponentWrapper>

<style lang="scss">
	.main-wrapper {
		display: grid;
		grid-template-columns: 4fr 3fr;
		margin-bottom: var(--space-10);
		gap: var(--space-15);
		flex: 1;
		align-items: center;

		h4 {
			font-size: var(--font-size-4);
			margin-bottom: var(--space-1);
		}

		.content-wrapper {
			margin-top: var(--space-2);
			display: flex;
			flex-direction: row;
			flex-wrap: wrap;
			gap: var(--space-3);
			align-items: flex-start;

			.card {
				padding: var(--space-4);
				background-color: transparent;
				border-radius: var(--radius-2);
				background-color: var(--clr-background-primary);
			}
		}

		.target {
			position: absolute;
			right: -99999px;
		}
	}
</style>
