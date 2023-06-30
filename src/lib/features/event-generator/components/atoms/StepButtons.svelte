<script lang="ts">
	import { Button } from '@emerald-dao/component-library';
	import type { createActiveStep } from '$stores/custom/steps/ActiveStep';
	import type { createSteps } from '$stores/custom/steps/Steps';
	import Icon from '@iconify/svelte';
	import captureDomToPng from '$lib/utilities/captureDomToPng';

	export let activeStepStore: ReturnType<typeof createActiveStep>;
	export let stepsStore: ReturnType<typeof createSteps>;
	export let stepDataValid: boolean;

	export const captureFloat = async () => {
		let capturedImageSrc: string;

		let elementToCapture = document.getElementById('target-element');
		let poweredByStyle = document.getElementById('powered-by-style');
		let titleStyle = document.getElementById('title-style');

		capturedImageSrc = await captureDomToPng(elementToCapture, poweredByStyle, titleStyle);
	};
</script>

<div class="row-space-between">
	<div>
		{#if $activeStepStore > 0}
			<Button on:click={() => activeStepStore.decrement()} color="neutral" type="transparent">
				<Icon icon="tabler:arrow-left" />
				Back
			</Button>
		{/if}
	</div>

	{#if $stepsStore[$activeStepStore].button.text !== 'Create Event'}
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
	{:else}
		<Button on:click={captureFloat} size="large" state={stepDataValid ? 'active' : 'disabled'}>
			{#if $stepsStore[$activeStepStore].button}
				{$stepsStore[$activeStepStore].button.text}
			{:else}
				Next
			{/if}
			<Icon icon={$stepsStore[$activeStepStore].button.icon ?? 'tabler:arrow-right'} />
		</Button>
	{/if}
</div>
