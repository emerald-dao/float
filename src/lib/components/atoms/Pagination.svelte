<script lang="ts">
	import Icon from '@iconify/svelte';

	export let itemsPerPage = 10;
	export let totalItems: number;
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

<slot />
<div>
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
	{/if}
</div>

<style lang="scss">
	.pagination {
		display: grid;
		grid-template-columns: 1fr 3fr 1fr;
		gap: var(--space-3);

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
</style>
