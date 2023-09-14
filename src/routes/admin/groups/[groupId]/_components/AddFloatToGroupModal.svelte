<script lang="ts">
	import { user } from '$lib/stores/flow/FlowStore';
	import { enhance } from '$app/forms';
	import { getFLOATs } from '$flow/actions';
	import Pagination from '$lib/components/atoms/Pagination.svelte';
	import type { FLOAT } from '$lib/types/float/float.interface';
	import { createSearchStore, searchHandler } from '$stores/searchBar';
	import { Button, Modal, getModal } from '@emerald-dao/component-library';
	import Icon from '@iconify/svelte';
	import { onDestroy, onMount } from 'svelte';
	import FloatCard from '../../../my-collection/_components/FloatCard/FloatCard.svelte';
	import SelectedFloatCard from './SelectedFloatCard.svelte';
	import ItemsListWrapper from '$lib/components/atoms/ItemsListWrapper.svelte';

	export let groupId: string;
	export let idsOnTheGroup: string[];

	$: id = `add-float-to-group-${groupId}`;

	let floats: FLOAT[] = [];

	let paginationMax: number;
	let paginationMin: number;

	let selectedFloatsIds: string[] = [];

	onMount(async () => {
		let allFloats = await getFLOATs($user.addr);

		floats = allFloats.filter((float) => !idsOnTheGroup.includes(float.id));
	});

	const handleSelectFloat = (floatId: string) => {
		if (selectedFloatsIds.includes(floatId)) {
			selectedFloatsIds = selectedFloatsIds.filter((id) => id !== floatId);
			return;
		} else {
			selectedFloatsIds = [...selectedFloatsIds, floatId];
		}
	};

	const handleAddFloats = () => {
		getModal(id).close();
		selectedFloatsIds = [];
	};

	const handleOpenModal = () => {
		getModal(id).open();
	};

	$: searchEvent = floats.map((example) => ({
		...example,

		searchTerms: `${example.eventName} ${example.eventId}`
	}));

	$: searchStore = createSearchStore(searchEvent);

	$: unsubscribe = searchStore.subscribe((model) => searchHandler(model));

	onDestroy(() => {
		unsubscribe();
	});
</script>

<Button on:click={handleOpenModal} size="small">
	Add FLOAT
	<Icon icon="tabler:plus" />
</Button>
<Modal {id} background="var(--clr-surface-primary)">
	<div class="main-wrapper">
		<div class="column-4 column-space-between">
			<div class="column-5">
				<div class="column-2">
					<span>Select the FLOATs you want to add</span>
					<input type="text" placeholder="Search FLOAT..." bind:value={$searchStore.search} />
				</div>
				<ItemsListWrapper numberOfItems={$searchStore.filtered.length}>
					<div class="column-3">
						{#each $searchStore.filtered as float, i}
							{#if i < paginationMax && i >= paginationMin}
								<FloatCard
									{float}
									hasLink={false}
									selected={selectedFloatsIds.includes(float.id)}
									on:floatClicked={(e) => handleSelectFloat(e.detail)}
									clickable={true}
								/>
							{/if}
						{/each}
					</div>
				</ItemsListWrapper>
			</div>
			<Pagination
				itemsPerPage={4}
				totalItems={$searchStore.filtered.length}
				bind:paginationMax
				bind:paginationMin
			/>
		</div>
		<form
			method="POST"
			action="?/addFloatsToGroup"
			class="column-4 column-space-between align-end"
			use:enhance
		>
			<div class="column-3 float-cards-wrapper">
				{#if selectedFloatsIds.length > 0}
					{#each selectedFloatsIds as floatId}
						{@const float = floats.find((float) => float.id === floatId)}
						{#if float !== undefined}
							<SelectedFloatCard
								{float}
								on:delete={() => {
									selectedFloatsIds = selectedFloatsIds.filter((id) => id !== floatId);
								}}
							/>
						{/if}
					{/each}
				{:else}
					<div class="empty-state">
						<span><em>No FLOATs selected</em></span>
					</div>
				{/if}
			</div>
			<input type="hidden" name="groupId" value={groupId} />
			<input type="hidden" name="floatIds" value={selectedFloatsIds.join(',')} />
			<Button
				size="small"
				state={selectedFloatsIds.length === 0 ? 'disabled' : 'active'}
				on:click={() => handleAddFloats()}><Icon icon="tabler:plus" />Add to Group</Button
			>
		</form>
	</div>
</Modal>

<style lang="scss">
	.main-wrapper {
		display: grid;
		grid-template-columns: 1fr 1fr;
		gap: var(--space-12);

		@include mq(medium) {
			width: 67vw;
			max-width: 1100px;
			height: 70vh;
			min-height: 500px;
			height: 650px;
		}

		form {
			overflow-y: hidden;

			.float-cards-wrapper {
				width: 100%;
				height: 100%;
				padding: var(--space-8);
				overflow-y: auto;
				overflow-x: hidden;
				border: 1px dashed var(--clr-border-primary);
				border-radius: var(--radius-3);
			}

			.empty-state {
				width: 100%;
				height: 100%;
				display: flex;
				align-items: center;
				justify-content: center;
			}
		}
	}
</style>
