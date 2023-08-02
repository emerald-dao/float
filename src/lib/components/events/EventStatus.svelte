<script lang="ts">
	import { Label } from '@emerald-dao/component-library';

	export let status: boolean;

	$: text = status ? 'Claimable' : 'Not claimable';
	$: color = status ? ('primary' as const) : ('alert' as const);
</script>

<div class="main-wrapper">
	<span class="title xsmall">Status</span>
	<div class="state-wrapper" style={`background-color: var(--clr-${color}-badge)`}>
		<span class="xsmall" style={`color: var(--clr-${color}-main)`}>
			{text}
		</span>
	</div>
</div>

<style lang="scss">
	.main-wrapper {
		border: 1px solid var(--clr-border-primary);
		border-radius: var(--radius-1);
		flex: 1;

		.state-wrapper {
			border-top: 1px solid var(--clr-border-primary);
		}

		.title,
		.state-wrapper {
			padding: var(--space-1) var(--space-3);
		}
	}
</style>
