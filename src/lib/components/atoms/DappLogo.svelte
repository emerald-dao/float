<script lang="ts">
	export let size = '1rem';
</script>

<div class="logo-wrapper" style={`font-size: ${size}`}>
	<img src="/float-logo.svg" alt="FLOAT logo" />
	<span class="w-medium">FLOAT</span>
</div>

<style lang="scss">
	.logo-wrapper {
		display: flex;
		align-items: center;
		gap: 0.5em;

		img {
			width: 2.5em;
			display: inline;
		}

		span {
			font-size: 1.4em;
			font-weight: 700;
			display: inline;
			color: var(--clr-heading-main);
			letter-spacing: -0.01em;
		}
	}
</style>
