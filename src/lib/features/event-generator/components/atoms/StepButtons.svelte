<script lang="ts">
	import { Button } from '@emerald-dao/component-library';
	import type { createActiveStep } from '$stores/custom/steps/ActiveStep';
	import type { createSteps } from '$stores/custom/steps/Steps';
	import Icon from '@iconify/svelte';

	export let activeStepStore: ReturnType<typeof createActiveStep>;
	export let stepsStore: ReturnType<typeof createSteps>;
	export let stepDataValid: boolean;
</script>

<div class="main-wrapper row-space-between">
	{#if $activeStepStore > 0}
		<div>
			<Button on:click={() => activeStepStore.decrement()} color="neutral" type="transparent">
				<Icon icon="tabler:arrow-left" />
				<span class="hide-on-mobile"> Back </span>
			</Button>
		</div>
	{:else}
		<div class="hide-on-small" />
	{/if}
	<Button
		on:click={() => activeStepStore.increment()}
		size="large"
		state={stepDataValid ? 'active' : 'disabled'}
	>
		{#if $stepsStore[$activeStepStore].button}
			{$stepsStore[$activeStepStore].button.text}
		{:else}
			Next
		{/if}
		<Icon icon={$stepsStore[$activeStepStore].button.icon ?? 'tabler:arrow-right'} />
	</Button>
</div>

<style lang="scss">
	.main-wrapper {
		gap: var(--space-10);
		align-items: center;
		position: fixed;
		bottom: 0;
		left: 0;
		width: 100%;
		background-color: var(--clr-surface-secondary);
		padding: var(--space-4) var(--space-6);
		z-index: 1;
		box-shadow: 0px 2px 6px 0 var(--clr-shadow-primary);

		@include mq(medium) {
			position: static;
			background-color: transparent;
			padding: 0;
			box-shadow: none;
		}

		.hide-on-small {
			display: none;

			@include mq(small) {
				display: block;
			}
		}
	}
</style>
