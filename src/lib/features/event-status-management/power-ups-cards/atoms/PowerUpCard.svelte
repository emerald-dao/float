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

<div class="main-wrapper shadow-small">
	<div class="title-wrapper">
		<Icon {icon} inline />
		<span class="w-medium">
			{name}
		</span>
	</div>
	<slot {PowerUpCard} />
</div>

<style lang="scss">
	.main-wrapper {
		border-radius: var(--radius-1);
		background-color: var(--clr-background-primary);
		overflow: hidden;
		display: flex;
		flex-direction: column;
		border-color: var(--clr-neutral-badge);
		background-color: var(--clr-background-primary);
		flex: 1;
		min-width: fit-content;
		max-width: fit-content;

		.title-wrapper {
			padding: 0em 1.2em;
			border-bottom: 1px dashed var(--clr-neutral-badge);
			font-size: 0.7em;
			color: var(--clr-text-off);

			span {
				line-height: 1;
			}
		}
	}
</style>
