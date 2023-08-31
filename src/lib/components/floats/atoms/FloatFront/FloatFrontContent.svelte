<script lang="ts">
	import Body from './FloatFrontBody.svelte';
	import Footer from './FloatFrontFooter.svelte';
	import Header from './FloatFrontHeader.svelte';

	const F = {
		Body,
		Footer,
		Header
	};
</script>

<div class="float-content">
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
	}
</style>
