<script lang="ts">
	import type { FloatColors } from '../../float-colors.type';

	export let color: FloatColors = 'neutral';
</script>

<div class={`body-wrapper ${color}`}>
	<slot />
</div>

<style lang="scss">
	.body-wrapper {
		padding: 2.5% 5.5%;
		display: flex;
		flex-direction: column;
		justify-content: space-between;
		gap: 0.4em;
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
