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
	import Icon from '@iconify/svelte';
	import { resolveAddressOrFindName } from '../functions/resolveAddressOrFindName';
	import { getContext } from 'svelte';
	import type createFetchStore from '../../../../routes/admin/_stores/fetchStore';

	export let event: Event;

	const eventsStore: ReturnType<typeof createFetchStore> = getContext('events');

	let certificateType = EVENT_TYPE_DETAILS[event.eventType].certificateType;

	let csvFiles: File[] = [];

	let distribution: Distribution<typeof certificateType> = {
		certificateType,
		distributionObjects: []
	};

	let addressInputValue = '';
	let csvDist: DistributionElement<typeof certificateType>[] = [];

	$: id = `distribute-floats-${$page.params.id}`;

	const resolveMedalType = () => {
		if (certificateType === 'medal') {
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
		} else {
			return null;
		}
	};

	const addToStagingFromInput = async () => {
		const resolvedAddress = await resolveAddressOrFindName(addressInputValue);

		if (!distribution.distributionObjects.find((obj) => obj.address === resolvedAddress)) {
			distribution.distributionObjects = [
				...distribution.distributionObjects,
				{
					address: resolvedAddress,
					medal: resolveMedalType()
				}
			];

			addressInputValue = '';
		} else {
			alert('Address already added');
		}
	};

	const addToStagingFromCsv = () => {
		for (let i = 0; i < csvDist.length; i++) {
			if (!distribution.distributionObjects.find((obj) => obj.address === csvDist[i].address)) {
				distribution.distributionObjects = [...distribution.distributionObjects, csvDist[i]];
			}
		}

		csvFiles = [];
	};

	const handleOpenModal = () => {
		getModal(id).open();
	};

	const handleDistributeFloats = async () => {
		await distributeFloats($page.params.id, distribution);
		getModal(id).close();
		eventsStore.invalidate();
	};
</script>

<Button on:click={handleOpenModal} size="small">
	<Icon icon="tabler:arrows-move" />
	Distribute FLOATs
</Button>
<Modal {id} background="var(--clr-background-primary)">
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
				bind:distribution
				bind:csvFiles
				{addToStagingFromInput}
				{addToStagingFromCsv}
				{certificateType}
			/>
		</div>
		<div class="dist-wrapper sub-wrapper align-end">
			<DistributionStaging bind:distribution {certificateType} />
			<div class="button-wrapper" transition:fly|local={{ y: 10, duration: 400, delay: 100 }}>
				<Button
					width="extended"
					size="large"
					on:click={handleDistributeFloats}
					state={distribution.distributionObjects.length > 0 ? 'active' : 'disabled'}
					>Distribute FLOATs <Icon icon="tabler:arrow-right" /></Button
				>
			</div>
		</div>
	</div>
</Modal>

<style lang="scss">
	.main-wrapper {
		display: flex;
		flex-direction: column;
		height: 70vh;
		width: 70vw;
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
				overflow: visible;

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
