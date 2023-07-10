<script lang="ts">
	export let actualStatus: {
		status: string;
		daysRemaining: number;
	};
</script>

{#if actualStatus.status === 'NotStarted'}
	<p>{actualStatus.daysRemaining} days to start</p>
{:else if actualStatus.status === 'InProgress'}
	<p>{actualStatus.daysRemaining} days left</p>
{:else}
	<p>Finished</p>
{/if}
