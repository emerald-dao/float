<script lang="ts">
	import { fly } from 'svelte/transition';
	import { eventGeneratorData } from '$lib/features/event-generator/stores/EventGeneratorData';
	import type { PowerUpType } from '$lib/features/event-generator/types/event-generator-data.interface';
	import Icon from '@iconify/svelte';
	import type { PowerUpGeneratorData } from '../powerUps';
	import { Button } from '@emerald-dao/component-library';

	export let powerUpData: PowerUpGeneratorData<PowerUpType>;

	const handleTogglePowerUp = (powerUpType: PowerUpType) => {
		eventGeneratorData.update((data) => {
			data.powerups[powerUpType].active = !data.powerups[powerUpType].active;
			return data;
		});
	};

	$: powerUpActive = $eventGeneratorData.powerups[powerUpData.type].active === true;
</script>

<div class="main-wrapper">
	<div class="introduction-wrapper">
		<div class="title-wrapper row-space-between">
			<h4 class="title row-2 align-center">
				<Icon icon={powerUpData.icon} />
				{powerUpData.name}
			</h4>
			{#if powerUpActive}
				<Button
					size="small"
					type="ghost"
					color="neutral"
					on:click={() => handleTogglePowerUp(powerUpData.type)}
				>
					<Icon icon="tabler:minus" />
					Deactivate PowerUp
				</Button>
			{:else}
				<Button size="small" on:click={() => handleTogglePowerUp(powerUpData.type)}>
					<Icon icon="tabler:plus" />
					Activate PowerUp
				</Button>
			{/if}
		</div>
		<span class="description small">
			{powerUpData.description}
		</span>
	</div>
	<div
		class="card-primary column-5"
		in:fly={{ y: 60, duration: 800 }}
		class:inavtive={!powerUpActive}
	>
		<slot />
	</div>
</div>

<style lang="scss">
	.main-wrapper {
		display: flex;
		flex-direction: column;
		flex: 1;
		min-width: 100%;

		.introduction-wrapper {
			margin-bottom: var(--space-6);
			padding-inline: var(--space-6);

			.title-wrapper {
				margin-bottom: var(--space-4);
				gap: var(--space-15);

				h4 {
					color: var(--clr-heading-main);
					font-size: var(--font-size-5);
				}
			}
		}

		.card-primary {
			padding: var(--space-6) var(--space-6) var(--space-4) var(--space-6);

			&.inavtive {
				opacity: 0.3;
			}
		}
	}
</style>
