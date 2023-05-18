<script lang="ts">
	const circlesAmount = 10;
	const baseCircleSize = 10;
	const circlesSizeIncrement = 10;
	const opacityIncrement = 0.1;
</script>

<div class="main-wrapper center">
	{#each Array(circlesAmount).fill(0) as circle, i}
		<div
			class="circle"
			style={`width: ${baseCircleSize + i * circlesSizeIncrement}rem; opacity: ${
				1 - i * opacityIncrement
			};`}
		/>
	{/each}
</div>

<style lang="scss">
	.main-wrapper {
		flex: 1;
		position: relative;

		.circle {
			position: absolute;
			border-radius: 50%;
			aspect-ratio: 1/1;
			border: 2px dashed var(--clr-neutral-200);
			animation: rotation 220s linear infinite;
		}
	}

	@keyframes rotation {
		0% {
			transform: rotate(0deg);
		}
		100% {
			transform: rotate(360deg);
		}
	}
</style>
