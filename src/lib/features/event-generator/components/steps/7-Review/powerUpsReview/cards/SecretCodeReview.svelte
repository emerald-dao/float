<script lang="ts">
	import { eventGeneratorData } from '$lib/features/event-generator/stores/EventGeneratorData';
	import type { EventWithStatus } from '$lib/types/event/event.interface';
	import type { Secret } from '$lib/types/event/verifiers.interface';
	import Icon from '@iconify/svelte';
	import { POWER_UPS, type PowerUpGeneratorData } from '../../../6-PowerUps/powerUps';
	import PowerUpReviewCard from '../atoms/PowerUpReviewCard.svelte';

	export let event: EventWithStatus | null = null;

	const paymentPowerUp = POWER_UPS.find(
		(powerUp) => powerUp.type === 'secretCode'
	) as PowerUpGeneratorData<'secretCode'>;

	let powerUpData = {
		active: false,
		data: ''
	};

	let secretCode: string;
	let visible = true;

	if ($eventGeneratorData.powerups.secretCode.active) {
		powerUpData = $eventGeneratorData.powerups.secretCode;
	} else if (event) {
		event.verifiers.forEach((verifier) => {
			if (verifier.hasOwnProperty('publicKey')) {
				secretCode = (verifier as Secret).publicKey;
			}
		});
	}
</script>

<PowerUpReviewCard name={paymentPowerUp.name} icon={paymentPowerUp.icon}>
	<div class="column align-center">
		<span class="small">
			{#if powerUpData.data}
				{powerUpData.data}
			{:else}
				<div class="input-wrapper row">
					{#if visible}
						<input type="password" value={secretCode} />
						<button class="eye-wrapper row align-center" on:click={() => (visible = !visible)}>
							<Icon icon="tabler:eye-off" />
						</button>
					{:else}
						<input type="text" value={secretCode} />
						<button class="eye-wrapper row align-center" on:click={() => (visible = !visible)}>
							<Icon icon="tabler:eye" />
						</button>
					{/if}
				</div>
			{/if}
		</span>
	</div>
</PowerUpReviewCard>

<style lang="scss">
	.column {
		padding: var(--space-1) var(--space-4);

		.input-wrapper {
			align-items: center;
			justify-content: center;
			input {
				padding: 0;
				border: none;
			}

			.eye-wrapper {
				cursor: pointer;
				background: none;
				border: none;
			}
		}
	}
</style>
