<script>
	export let isMedal = false;
</script>

<div class="body-wrapper" class:medal={isMedal}>
	<slot />
</div>

<style lang="scss">
	.body-wrapper {
		padding: 4% 5.5%;
		display: flex;
		flex-direction: column;
		justify-content: space-between;
		gap: 0.8em;
		border-block: 2px dashed var(--clr-neutral-badge);
		height: 100%;
		text-align: left;

		&.medal {
			border-color: rgba(218, 165, 32, 0.2);
		}
	}
</style>
