<script lang="ts">
	import Icon from '@iconify/svelte';
	import { createEventDispatcher } from 'svelte';
	import { fly } from 'svelte/transition';

	const dispatch = createEventDispatcher();

	export let itemsPerPage = 10;
	export let totalItems: number;
	export let noItemsMessage = 'No items found';
	export let paginationMin: number;
	export let paginationMax: number;

	let activePage = 0;

	$: numberOfPages = Math.ceil(totalItems / itemsPerPage);
	$: paginationMin = activePage * itemsPerPage;
	$: paginationMax = paginationMin + itemsPerPage;

	const handleNextPage = () => {
		if (activePage < numberOfPages - 1) {
			activePage += 1;
		}
	};

	const handlePreviousPage = () => {
		if (activePage > 0) {
			activePage -= 1;
		}
	};
</script>

<div class="wrapper" in:fly={{ x: 10, duration: 400 }}>
	<slot />
	{#if numberOfPages > 0}
		<div class="pagination">
			<div>
				<div on:click={handlePreviousPage} class="header-link" class:disabled={activePage === 0}>
					<Icon icon="tabler:arrow-left" />
				</div>
			</div>
			<div class="page-number">
				<span class="xsmall">
					{activePage + 1}
					<span class="off">
						/ {numberOfPages}
					</span>
				</span>
			</div>
			<div class="justify-end">
				<div
					on:click={handleNextPage}
					class="header-link"
					class:disabled={activePage === numberOfPages - 1}
				>
					<Icon icon="tabler:arrow-right" />
				</div>
			</div>
		</div>
	{:else if totalItems === 0}
		<div class="no-items-wrapper">
			<p><em>{noItemsMessage}</em></p>
		</div>
	{/if}
</div>

<style lang="scss">
	.pagination {
		display: grid;
		grid-template-columns: 1fr 3fr 1fr;
		padding-top: var(--space-4);

		.off {
			color: var(--clr-text-off);
		}

		& > div {
			display: flex;
			flex-direction: row;
			align-items: center;
		}

		.page-number {
			display: flex;
			justify-content: center;
		}

		.disabled {
			pointer-events: none;
			opacity: 0.3;
		}
	}
	.no-items-wrapper {
		display: flex;
		justify-content: center;
		padding-block: var(--space-14) var(--space-10);
		p {
			color: var(--clr-text-off);
		}
	}
</style>
