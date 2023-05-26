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
		opacity: 0.7;
		cursor: pointer;

		span:first-child {
			color: var(--clr-heading-main);
		}

		&.active {
			opacity: 1;
			border-color: var(--clr-primary-main);
			background-color: var(--clr-primary-badge);
		}
	}
</style>
