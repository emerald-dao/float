<script lang="ts">
	import Icon from '@iconify/svelte';

	export let actualStatus: {
		status: string;
		daysRemaining: number;
	};
</script>

{#if actualStatus}
	<div class="status-wrapper {actualStatus.status === 'InProgress' ? 'active' : 'inactive'}">
		{#if actualStatus.status === 'NotStarted'}
			<Icon icon="tabler:circle-filled" color="var(--clr-neutral-300)" width="9" />
			<p class="xsmall" style="color: var(--clr-neutral-200);">inactive</p>
		{:else if actualStatus.status === 'InProgress'}
			<Icon icon="tabler:circle-filled" color="var(--clr-primary-main)" width="9" />
			<p class="xsmall" style="color: var(--clr-primary-main);">active</p>
		{:else}
			<Icon icon="tabler:circle-filled" color="var(--clr-neutral-300)" width="9" />
			<p class="xsmall" style="color: var(--clr-neutral-200);">inactive</p>
		{/if}
	</div>
{:else}
	<div class="status-wrapper active">
		<Icon icon="tabler:circle-filled" color="var(--clr-primary-main)" width="9" />
		<p class="xsmall" style="color: var(--clr-primary-main);">active</p>
	</div>
{/if}

<style lang="scss">
	.status-wrapper {
		display: flex;
		align-items: center;
		justify-content: center;
		padding: var(--space-1) var(--space-3);
		border-radius: var(--radius-1);
		text-align: center;
		gap: var(--space-1);
	}

	.active {
		background-color: var(--clr-primary-badge);
	}

	.inactive {
		background-color: var(--clr-neutral-badge);
	}
</style>
