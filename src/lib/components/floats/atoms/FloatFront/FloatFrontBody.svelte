<div class="body-wrapper">
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
	}
</style>
