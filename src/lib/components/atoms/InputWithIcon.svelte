<script lang="ts">
	import Icon from '@iconify/svelte';

	export let icon: string;
</script>

<div class="input-wrapper">
	<div class="icon-wrapper-left">
		<Icon {icon} />
	</div>
	<slot />
</div>

<style lang="scss">
	.input-wrapper {
		width: 100%;
		border: 1px var(--clr-border-primary) solid;
		border-radius: var(--radius-1);
		display: flex;
		flex-direction: row;
		transition: 0.2s;

		.icon-wrapper-left {
			color: var(--clr-text-off);
			display: flex;
			align-items: center;
			flex-direction: row;
			padding-inline: 0.5rem;
			transition: 0.2s;
			border-right: 1px var(--clr-border-primary) solid;
			justify-content: center;
			min-width: 3rem;

			img {
				width: 26px;
			}

			span {
				font-size: var(--font-size-1);
			}
		}

		&:has(input:focus) {
			border-color: var(--clr-text-main);

			.icon-wrapper-left {
				border-right-color: var(--clr-text-main);
				color: var(--clr-text-main);
			}
		}

		:global(input) {
			display: flex;
			flex: 1;
			border: none;
			padding-inline: var(--space-2) var(--space-1);
		}
	}
</style>
