<script lang="ts">
	import Icon from '@iconify/svelte';
	import PowerUpReviewCard from '../atoms/PowerUpCard.svelte';
	import { POWER_UPS } from '$lib/features/event-generator/components/steps/7-PowerUps/powerUps';

	export let secretCode: string;
	export let isAdmin: boolean = false;

	const paymentPowerUp = POWER_UPS['secret'];

	let visible = true;
</script>

<PowerUpReviewCard name={paymentPowerUp.name} icon={paymentPowerUp.icon} let:PowerUpCard>
	<PowerUpCard.Content>
		<div class="input-wrapper row">
			{#if isAdmin}
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
			{:else}
				<span>••••••••••</span>
			{/if}
		</div>
	</PowerUpCard.Content>
</PowerUpReviewCard>

<style lang="scss">
	.input-wrapper {
		align-items: center;
		justify-content: space-between;

		input {
			padding: 0;
			border: none;
			font-size: 0.8em;
		}

		.eye-wrapper {
			cursor: pointer;
			background: none;
			border: none;
			color: var(--clr-text-off);
		}
	}
</style>
