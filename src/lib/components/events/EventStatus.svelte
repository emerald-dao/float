<script lang="ts">
	import Icon from '@iconify/svelte';

	export let actualStatus: {
		status: string;
		daysRemaining: number;
	};
</script>

{#if actualStatus}
	<div
		class="status-wrapper"
		style="background-color: {actualStatus.status === 'InProgress'
			? 'var(--clr-primary-badge)'
			: 'var(--clr-neutral-800)'};"
	>
		{#if actualStatus.status === 'NotStarted'}
			<Icon icon="ion:ellipse-sharp" color="var(--clr-neutral-300)" />
			<p class="xsmall" style="color: var(--clr-neutral-200);">inactive</p>
		{:else if actualStatus.status === 'InProgress'}
			<Icon icon="ion:ellipse-sharp" color="var(--clr-primary-main)" />
			<p class="xsmall" style="color: var(--clr-primary-main);">active</p>
		{:else}
			<Icon icon="ion:ellipse-sharp" color="var(--clr-neutral-300)" />
			<p class="xsmall" style="color: var(--clr-neutral-200);">inactive</p>
		{/if}
	</div>
{:else}
	<div class="status-wrapper" style="background-color: var(--clr-primary-badge);">
		<Icon icon="ion:ellipse-sharp" color="var(--clr-primary-main)" />
		<p class="xsmall" style="color: var(--clr-primary-main);">active</p>
	</div>
{/if}

<style lang="scss">
	.status-wrapper {
		display: flex;
		width: fit-content;
		padding: var(--space-1) var(--space-2);
		border-radius: var(--radius-1);
		text-align: center;
		gap: var(--space-1);
	}
</style>
