<script lang="ts">
	import { fly } from 'svelte/transition';
	import { eventGeneratorData } from '$lib/features/event-generator/stores/EventGeneratorData';
	import type { PowerUpType } from '$lib/features/event-generator/types/event-generator-data.interface';
	import Icon from '@iconify/svelte';
	import type { PowerUp } from '../powerUps';

	export let powerUpData: PowerUp<PowerUpType>;

	const handleTogglePowerUp = (powerUpType: PowerUpType) => {
		eventGeneratorData.update((data) => {
			data.powerups[powerUpType].active = !data.powerups[powerUpType].active;
			return data;
		});
	};

	$: powerUpActive = $eventGeneratorData.powerups[powerUpData.type].active === true;
</script>

<div class="card-primary column-5" in:fly={{ y: 60, duration: 800 }}>
	<div>
		<div class="title-wrapper row-space-between">
			<span class="title row-2 align-center">
				<Icon icon={powerUpData.icon} />
				{powerUpData.name}
			</span>
			<label for={`active-${powerUpData.type}`} class="switch">
				<input
					type="checkbox"
					name={`active-${powerUpData.type}`}
					id={`active-${powerUpData.type}`}
					checked={powerUpActive}
					on:change={() => handleTogglePowerUp(powerUpData.type)}
				/>
				<span class="slider" />
			</label>
		</div>
		<span class="description small">
			{powerUpData.description}
		</span>
	</div>
	<slot />
</div>

<style lang="scss">
	.card-primary {
		.title-wrapper {
			margin-bottom: var(--space-3);

			span {
				color: var(--clr-heading-main);
				font-size: var(--font-size-4);
			}
		}

		.description {
			padding-bottom: var(--space-4);
		}
	}
</style>
