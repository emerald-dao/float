<script type="ts">
	export let route: string | null;
</script>

<div class="header-wrapper row">
	<img src="/test-toucan.png" alt="float" />
	<p>mateor.find / {route}</p>
</div>

<style type="scss">
	.header-wrapper {
		padding: var(--space-3) var(--space-10);
		align-items: center;
		top: 10px;
		z-index: 1000;
		background-color: var(--clr-background-primary);
		gap: var(--space-4);

		img {
			width: 56px;
			height: 56px;
			border-radius: 50%;
		}

		p {
			color: var(--clr-heading-main);
		}
	}
</style>
