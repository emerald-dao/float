<script lang="ts">
	import Icon from '@iconify/svelte';

	export let canBeEditedLater: boolean | null = null;
</script>

{#if canBeEditedLater === true}
	<div class="row-1 align-center editable">
		<Icon icon="tabler:edit" />
		<p class="xsmall">Editable after launch</p>
	</div>
{:else if canBeEditedLater === false}
	<div class="row-1 align-center not-editable">
		<Icon icon="tabler:edit-off" />
		<p class="xsmall">Not editable after launch</p>
	</div>
{/if}

<style lang="scss">
	.editable {
		color: var(--clr-primary-main);
		opacity: 0.7;
	}

	.not-editable {
		opacity: 0.7;
	}

	p {
		color: inherit;
	}
</style>
