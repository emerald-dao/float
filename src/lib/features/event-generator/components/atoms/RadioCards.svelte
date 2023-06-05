<script lang="ts">
	export let options: Options[];
	export let selectedValue: string | boolean;

	interface Options {
		value: string | boolean;
		title: string;
		description: string;
	}
</script>

{#each options as { value, title, description }}
	<div
		class="card column-1"
		on:click={() => (selectedValue = value)}
		class:active={selectedValue === value}
	>
		<span class="w-medium">{title}</span>
		<span class="small">{description}</span>
	</div>
{/each}

<style lang="scss">
	.card {
		opacity: 0.6;
		cursor: pointer;
		transition: 0.6s;
		border: none;
		background-color: var(--clr-neutral-badge);

		span:first-child {
			transition: 0.6s;
			color: var(--clr-heading-main);
		}

		&.active {
			opacity: 1;
			background-color: var(--clr-primary-badge);

			span:first-child {
				color: var(--clr-primary-main);
			}
		}
	}
</style>
