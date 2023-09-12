<script lang="ts">
	export let symbol: string;
	export let fontSize = '1rem';
</script>

<div style={`font-size: ${fontSize}`}>
	<p>{symbol}</p>
</div>

<style lang="scss">
	div {
		p {
			min-width: 1.7em;
			background-color: var(--clr-neutral-badge);
			padding: 0.3em 0.3em;
			border-radius: 0.23em;
			opacity: 0.7;
			font-size: 1em;
			color: var(--clr-text-main);
			border: 1px solid var(--clr-neutral-badge);
			width: 100%;
			display: flex;
			justify-content: center;
			align-items: center;
			line-height: 1.1em;
		}
	}
</style>
