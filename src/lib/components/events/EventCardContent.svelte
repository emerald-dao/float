<script lang="ts">
	import { POWER_UPS } from '$lib/features/event-generator/components/steps/7-PowerUps/powerUps';
	import type { EventWithStatus } from '$lib/types/event/event.interface';
	import EventStatus from './EventStatus.svelte';
	import FloatEventType from '../floats/atoms/FloatEventType.svelte';
	import Icon from '@iconify/svelte';
	import type { PowerUpType } from '$lib/features/event-generator/types/event-generator-data.interface';

	export let event: EventWithStatus;
	export let display: 'grid' | 'list' = 'list';
	export let displayedInAdmin = true;

	let verifiersList = Object.keys(event.verifiers) as PowerUpType[];
</script>

<div class={`main-wrapper ${display}`}>
	<div class={`general-info-wrapper `}>
		<div class="title-wrapper row-3">
			<img src={event.image} width="55px" height="55px" alt="logo" />
			<div class="name-wrapper">
				<p class="w-medium">{event.name}</p>
				<FloatEventType eventType={event.eventType} fontSize="0.8em" />
			</div>
		</div>
		<div
			class="minted-floats-wrapper"
			class:no-extra-info={display === 'list' && !displayedInAdmin}
		>
			<span class="w-medium">
				{Number(event.totalSupply).toLocaleString()} FLOATs
			</span>
			<span class="small"> claimed </span>
		</div>
	</div>
	<div class="secondary-wrapper">
		<div class="status-wrapper column align-center justify-center">
			<EventStatus
				status={event.status.generalStatus}
				claimability={event.claimable}
				timelockStatus={event.status.verifiersStatus.timelockStatus}
			/>
		</div>
		{#if verifiersList.length > 0 || (event.price && Number(event.price) > 0)}
			<div class="powerups-wrapper">
				<span class="power-ups-title">Powerups</span>
				<div class="labels-wrapper">
					{#each verifiersList as verifier}
						<span class="power-up-label">
							<Icon icon={POWER_UPS[verifier].icon} inline />
							{POWER_UPS[verifier].name}
						</span>
					{/each}
					{#if event.price && Number(event.price) > 0}
						<span class="power-up-label">
							<Icon icon={POWER_UPS['payment'].icon} inline />
							{POWER_UPS['payment'].name}
						</span>
					{/if}
				</div>
			</div>
		{/if}
	</div>
</div>

<style lang="scss">
	.main-wrapper {
		display: flex;
		flex-direction: column;
		justify-content: space-between;
		gap: var(--space-6);
		border: 1px solid var(--clr-border-primary);
		border-radius: var(--radius-2);
		width: 100%;
		transition: 300ms ease-in-out;
		background-color: var(--clr-surface-primary);
		flex: 1;

		&:hover {
			background: var(--clr-surface-secondary);
			box-shadow: 0px 2px 6px 0 var(--clr-shadow-primary);
		}

		.general-info-wrapper {
			display: flex;
			flex-direction: column;
			justify-content: center;
			gap: var(--space-7);
			padding: var(--space-8) var(--space-8) 0px var(--space-8);

			.title-wrapper {
				align-items: center;

				img {
					border-radius: var(--radius-0);
				}

				.name-wrapper {
					p {
						text-align: left;
						color: var(--clr-heading-main);
						font-size: var(--font-size-2);
					}

					span {
						text-align: center;
						width: fit-content;
						border: var(--border-width-primary) solid var(--clr-border-primary);
						padding: var(--space-1);
						border-radius: var(--radius-1);
					}
				}
			}
		}

		.secondary-wrapper {
			display: flex;
			border-top: 1px dashed var(--clr-border-primary);
			padding-inline: var(--space-2);

			.powerups-wrapper {
				border-left: 1px dashed var(--clr-border-primary);
				padding-inline: var(--space-4);
				display: flex;
				flex-direction: column;
				gap: var(--space-1);
				flex: 1;

				.power-ups-title {
					font-size: var(--font-size-0);
					padding-left: var(--space-2);
				}

				.labels-wrapper {
					display: flex;
					flex-direction: row;
					flex-wrap: wrap;
					gap: var(--space-2);

					.power-up-label {
						font-size: var(--font-size-0);
						color: var(--clr-text-off);
						background-color: var(--clr-surface-secondary);
						border: 1px solid var(--clr-neutral-badge);
						padding: 0 var(--space-2);
						border-radius: var(--radius-1);
					}
				}
			}

			.status-wrapper,
			.powerups-wrapper {
				padding: var(--space-5);
			}
		}

		&.list {
			display: grid;
			grid-template-columns: 1fr 1fr;
			padding: var(--space-1) var(--space-6);

			.no-extra-info {
				display: none;
			}

			.general-info-wrapper {
				display: grid;
				grid-template-columns: 2fr 1fr;
				align-items: center;
				padding: 0;
				gap: var(--space-12);
				justify-self: start;
			}

			.secondary-wrapper {
				flex-direction: row-reverse;
				align-items: center;
				border-top: none;
				padding: 0;
				justify-self: end;

				.powerups-wrapper {
					border-right: 1px dashed var(--clr-border-primary);
					height: 100%;
					border: none;
				}
			}
		}
	}
</style>
