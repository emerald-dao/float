<script lang="ts">
	import Icon from '@iconify/svelte';
	import State from './PowerUpCardState.svelte';
	import Content from './PowerUpCardContent.svelte';
	import Details from './PowerUpCardDetails.svelte';

	export let name: string;
	export let icon: string;

	const PowerUpCard = {
		Content,
		State,
		Details
	};
</script>

<div class="card">
	<div class="title-wrapper">
		<Icon {icon} inline />
		<span>
			{name}
		</span>
	</div>
	<slot {PowerUpCard} />
</div>

<style lang="scss">
	.card {
		padding: 0;
		border-radius: 0.6em;
		background-color: var(--clr-background-primary);
		overflow: hidden;
		display: flex;
		flex-direction: column;
		border: 0.5px solid var(--clr-border-primary);

		.title-wrapper {
			padding: 0em 0.7em;
			border-bottom: 1px dashed var(--clr-border-primary);
			background-color: var(--clr-background-secondary);
			font-size: 0.7em;
			color: var(--clr-text-main);

			span {
				line-height: 1;
			}
		}
	}
</style>
