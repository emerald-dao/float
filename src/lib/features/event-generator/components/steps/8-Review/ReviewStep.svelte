<script lang="ts">
	import { generatedNft } from '../../../stores/EventGeneratorData';
	import { eventGeneratorActiveStep } from '../../../stores/EventGeneratorSteps';
	import { fly } from 'svelte/transition';
	import { eventGeneratorData } from '$lib/features/event-generator/stores/EventGeneratorData';
	import Float from '$lib/components/floats/Float.svelte';
	import captureFloatTicket from '$lib/features/event-generator/actions/captureFloatTicket';
	import Blur from '$lib/components/Blur.svelte';
	import { onMount } from 'svelte';
	import StepComponentWrapper from '../atoms/StepComponentWrapper.svelte';
	import PowerUpsReview from '../atoms/PowerUpsReview.svelte';

	export let stepDataValid: boolean;

	let target: HTMLElement;

	onMount(async () => {
		// make timeout to make sure the float image rendered
		await new Promise((resolve) => setTimeout(resolve, 500));

		$eventGeneratorData.ticketImage = await captureFloatTicket(target);
	});

	$: stepDataValid = $eventGeneratorData.ticketImage !== null;
</script>

<StepComponentWrapper alignCenter={true}>
	<div class="main-wrapper">
		<div in:fly|local={{ x: -500, duration: 700 }} class="float-wrapper">
			<Float float={$generatedNft} showBack={$eventGeneratorActiveStep === 1} />
			<div class="screenshot-float-target-wrapper">
				<div id="screenshot-target" bind:this={target}>
					<Blur color="tertiary" right="0" top="30%" />
					<Blur left="0" bottom="20%" />
					<Float
						float={$generatedNft}
						showBack={$eventGeneratorActiveStep === 1}
						minWidth="600px"
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
					<div class="card">
						<span class="small">
							{#if $eventGeneratorData.multipleClaim}
								User can claim multiple
							{:else}
								User can only claim one
							{/if}
						</span>
					</div>
				</div>
			</div>
			<div class="column-3">
				<div>
					<h4 class="w-medium">+ Power Ups</h4>
					<p class="small">Can not be changed later.</p>
				</div>
				<PowerUpsReview />
			</div>
		</div>
	</div>
</StepComponentWrapper>

<style lang="scss">
	.main-wrapper {
		display: flex;
		flex-direction: column;
		margin-bottom: var(--space-10);
		gap: var(--space-15);
		flex: 1;
		align-items: center;

		@include mq(medium) {
			display: grid;
			grid-template-columns: 4fr 3fr;
		}

		h4 {
			font-size: var(--font-size-4);
			margin-bottom: var(--space-1);
		}

		.float-wrapper {
			width: 100%;
		}

		.content-wrapper {
			margin-top: var(--space-2);
			display: grid;
			grid-template-columns: 1fr 1fr;
			gap: var(--space-3);
			align-items: flex-start;

			.card {
				padding: var(--space-4);
				background-color: transparent;
				border-radius: var(--radius-2);
				background-color: var(--clr-background-primary);
			}
		}

		.screenshot-float-target-wrapper {
			position: absolute;
			right: -99999px;

			#screenshot-target {
				padding: var(--space-12);
				background-color: var(--clr-background-primary);
				position: relative;
			}
		}
	}
</style>
