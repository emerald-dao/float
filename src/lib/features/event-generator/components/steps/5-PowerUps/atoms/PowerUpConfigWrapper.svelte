<script lang="ts">
	import { fly } from 'svelte/transition';
	import { eventGeneratorData } from '$lib/features/event-generator/stores/EventGeneratorData';
	import type {
		PowerUpData,
		PowerUps
	} from '$lib/features/event-generator/types/event-generator-data.interface';
	import Icon from '@iconify/svelte';
	import POWER_UPS, { type PowerUp } from '../powerUps';

	export let powerUpData: PowerUp;

	const handleTogglePowerUp = (powerUpType: PowerUps) => {
		eventGeneratorData.update((data) => {
			if (data.powerups[powerUpType]) {
				delete data.powerups[powerUpType];
			} else {
				data.powerups[powerUpType] = POWER_UPS.find((powerUp) => powerUp.type === powerUpType)
					?.data as PowerUpData<typeof powerUpType>;
			}
			return data;
		});
	};

	$: powerUpActive = $eventGeneratorData.powerups[powerUpData.type] !== undefined;
</script>

<div class="card-primary column-5" in:fly={{ y: 60, duration: 800 }}>
	<div>
		<div class="title-wrapper row-space-between">
			<span class="title w-medium row-1 align-center">
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
			margin-bottom: var(--space-2);

			span {
				color: var(--clr-heading-main);
			}
		}

		.description {
			padding-bottom: var(--space-4);
		}
	}
</style>
