<script lang="ts">
	import Body from './FloatFrontBody.svelte';
	import Footer from './FloatFrontFooter.svelte';
	import Header from './FloatFrontHeader.svelte';

	export let color: 'primary' | 'gold' | 'silver' | 'bronze' = 'primary';

	const F = {
		Body,
		Footer,
		Header
	};
</script>

<div class={`float-content ${color}`}>
	<slot {F} />
</div>

<style lang="scss">
	.float-content {
		border: 2px solid var(--clr-neutral-badge);
		border-radius: 1.3em;
		width: 100%;
		height: 100%;
		display: flex;
		align-items: center;
		justify-content: center;
		overflow: hidden;
		display: grid;
		grid-template-rows: auto 1fr auto;
		grid-template-columns: 100%;

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
