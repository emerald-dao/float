<script lang="ts">
	import { page } from '$app/stores';
	import { getContext } from 'svelte';
	import type { Group } from '../_types/group.interface';
	import { getSpecificFLOATs } from '$flow/actions';
	import { supabase } from '$lib/supabase/supabaseClient';
	import FloatCard from '../../my-collection/_components/FloatCard/FloatCard.svelte';
	import AddFloatToGroupModal from './_components/AddFloatToGroupModal.svelte';
	import Icon from '@iconify/svelte';
	import Pagination from '$lib/components/atoms/Pagination.svelte';
	import ItemsListWrapper from '$lib/components/atoms/ItemsListWrapper.svelte';

	const groups: Group[] = getContext('groups');

	$: currentGroup = groups.find((g) => g.id === Number($page.params.groupId));

	let paginationMax: number;
	let paginationMin: number;

	const fetchGroupFloatsIds = async (groupId: string): Promise<string[]> => {
		const { data, error } = await supabase
			.from('floats_groups')
			.select('float_id')
			.eq('group_id', groupId);

		if (error) {
			console.error(error);
			return [];
		}

		return data.map((float) => float.float_id);
	};

	const userAddress = '0x99bd48c8036e2876';
</script>

<div class="main-wrapper">
	{#if currentGroup}
		<div class="title-wrapper">
			<h4>{currentGroup.name}</h4>
			{#if currentGroup.description}
				<p class="small">{currentGroup.description}</p>
			{/if}
		</div>
		{#await fetchGroupFloatsIds($page.params.groupId) then floatIds}
			{#await getSpecificFLOATs(userAddress, floatIds)}
				getting floats..
			{:then floats}
				<div class="column-4 content-wrapper">
					<ItemsListWrapper
						numberOfItems={floats.length}
						noItemsMessage="This groups has no FLOATs yet"
					>
						<div class="floats-wrapper">
							{#each floats as float, i}
								{#if i < paginationMax && i >= paginationMin}
									<div class="row-3 align-center">
										<FloatCard {float} />
										<form method="POST" action="?/deleteFloatFromGroup">
											<input type="hidden" name="groupId" value={$page.params.groupId} />
											<input type="hidden" name="floatId" value={float.id} />
											<button>
												<Icon icon="tabler:x" />
											</button>
										</form>
									</div>
								{/if}
							{/each}
						</div>
					</ItemsListWrapper>
				</div>
				<div class="bottom-wrapper">
					<Pagination
						itemsPerPage={6}
						totalItems={floats.length}
						noItemsMessage="No results found"
						bind:paginationMax
						bind:paginationMin
					/>
					<AddFloatToGroupModal groupId={$page.params.groupId} />
				</div>
			{/await}
		{/await}
	{:else}
		Group not found
	{/if}
</div>

<style lang="scss">
	.main-wrapper {
		display: flex;
		flex-direction: column;
		overflow-y: hidden;
		height: 100%;

		.title-wrapper {
			padding: var(--space-6) var(--space-10);
			border-bottom: 1px solid var(--clr-border-primary);

			h4 {
				font-size: var(--font-size-4);
				margin-bottom: var(--space-1);
			}
		}

		.content-wrapper {
			overflow-y: hidden;
			height: 100%;
			padding: var(--space-6) var(--space-10);

			.floats-wrapper {
				overflow-y: auto;
				display: flex;
				flex-direction: column;
				gap: var(--space-5);
				height: 100%;
				width: 100%;
			}

			button {
				all: unset;
				cursor: pointer;
			}
		}

		.bottom-wrapper {
			padding: var(--space-4) var(--space-10);
			display: flex;
			border-top: 1px solid var(--clr-border-primary);
			gap: var(--space-8);
			justify-content: space-between;
		}
	}
</style>
