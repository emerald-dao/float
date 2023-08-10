<script>
	import { fade, fly } from 'svelte/transition';

	export let numberOfCards = 3;
</script>

<div class="loading-cards">
	{#each Array(numberOfCards) as _, i}
		<div class="loading-card change-color" in:fly={{ duration: 2000, delay: 100 * i }} />
	{/each}
</div>

<style lang="scss">
	.loading-cards {
		display: flex;
		flex-direction: column;
		gap: var(--space-5);
		height: 100%;

		.loading-card {
			height: 100%;
			background-color: var(--clr-neutral-badge);
			border-radius: var(--radius-1);
		}

		.change-color {
			animation: change-color 3s infinite ease-in-out;
		}

		@keyframes change-color {
			0% {
				background-color: var(--clr-neutral-badge);
			}
			50% {
				background-color: var(--clr-neutral-900);
			}
			100% {
				background-color: var(--clr-neutral-badge);
			}
		}
	}
</style>
