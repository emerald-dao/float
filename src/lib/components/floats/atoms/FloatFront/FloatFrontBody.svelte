<script lang="ts">
	export let color: 'primary' | 'gold' | 'silver' | 'bronze' = 'primary';
</script>

<div class={`body-wrapper ${color}`}>
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

		&.gold {
			border-color: rgba(218, 165, 32, 0.2);
		}

		&.silver {
			border-color: rgba(192, 192, 192, 0.4);
		}

		&.bronze {
			border-color: rgba(232, 208, 184, 0.7);
		}
	}
</style>
