<script lang="ts">
	import { page } from '$app/stores';
	import DistributionStaging from './sections/DistributionStaging.svelte';
	import DistributionForms from './sections/DistributionForms.svelte';
	import { Button, Modal, getModal } from '@emerald-dao/component-library';
	import { fly } from 'svelte/transition';
	import { distributeFloats } from '../functions/distributeFloats';
	import type { Event } from '$lib/types/event/event.interface';
	import { EVENT_TYPE_DETAILS } from '$lib/types/event/event-type.type';
	import type { Distribution, DistributionElement } from '../types/distribution.interface';
	import type { MedalType } from '$lib/types/event/medal-types.type';

	export let event: Event;

	let certificateType = EVENT_TYPE_DETAILS[event.eventType].certificateType;

	let distribution: Distribution<typeof certificateType> = {
		certificateType,
		distributionObjects: []
	};

	let addressInputValue = '';
	let csvDist: DistributionElement<typeof certificateType>[] = [];

	let restartValidation: () => void;

	$: id = `distribute-floats-${$page.params.id}`;

	const resolveMedalType = () => {
		// if (certificateType === 'medal') {
		switch (distribution.distributionObjects.length) {
			case 0:
				return 'gold';
			case 1:
				return 'silver';
			case 2:
				return 'bronze';
			default:
				return 'participation';
		}
		// } else {
		// 	return null;
		// }
	};

	const addToStaging = () => {
		distribution.distributionObjects = [
			...distribution.distributionObjects,
			{
				address: addressInputValue,
				medal: resolveMedalType()
			},
			...csvDist
		];

		addressInputValue = '';
		restartValidation();
	};

	const handleOpenModal = () => {
		getModal(id).open();
	};

	const handleDistributeFloats = () => {
		distributeFloats($page.params.id, distribution);
	};
</script>

<Button on:click={handleOpenModal} size="small">Distribute FLOATs</Button>
<Modal {id} background="var(--clr-surface-primary)">
	<div class="main-wrapper">
		<div class="forms-wrapper sub-wrapper column">
			<div class="introduction">
				<h5 class="w-medium">Distribute FLOATs</h5>
				<p class="small">Add the wallets you want to distribute tokens to.</p>
			</div>
			<slot />
			<DistributionForms
				bind:addressInputValue
				bind:csvDist
				bind:restartValidation
				bind:distribution
				{addToStaging}
				{certificateType}
			/>
		</div>
		<div class="dist-wrapper sub-wrapper">
			<DistributionStaging bind:distribution {certificateType} />
			<div class="button-wrapper" transition:fly|local={{ y: 10, duration: 400, delay: 100 }}>
				<Button
					width="full-width"
					on:click={handleDistributeFloats}
					state={distribution.distributionObjects.length > 0 ? 'active' : 'disabled'}
					>Distribute FLOATs</Button
				>
			</div>
		</div>
	</div>
</Modal>

<style lang="scss">
	.main-wrapper {
		display: flex;
		flex-direction: column;
		height: 90vh;
		overflow-y: hidden;
		flex: 1;

		@include mq(small) {
			height: 75vh;
			width: 75vw;
			display: grid;
			grid-template-columns: 2fr 3fr;
			gap: var(--space-13);
		}

		.sub-wrapper {
			display: flex;
			flex-direction: column;
			gap: var(--space-3);
			overflow-y: hidden;
			transition: 3s;

			@include mq(small) {
				gap: 1.4rem;
			}

			&.dist-wrapper {
				flex: 1;
			}

			&.forms-wrapper {
				height: fit-content;
				margin-bottom: 0;
				padding-bottom: 0;

				.introduction {
					h5 {
						margin-bottom: var(--space-2);
						margin-top: 0;
					}
				}
			}

			.button-wrapper {
				position: sticky;
				bottom: 0px;
			}
		}
	}
</style>
