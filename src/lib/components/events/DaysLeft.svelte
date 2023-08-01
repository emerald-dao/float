<script lang="ts">
	import Icon from '@iconify/svelte';

	export let actualStatus: {
		status: string;
		daysRemaining: number;
	};
</script>

<span class="small row-1 align-center">
	<Icon icon="tabler:clock" />
	{#if actualStatus.status === 'NotStarted'}
		{actualStatus.daysRemaining} days to start
	{:else if actualStatus.status === 'InProgress'}
		{actualStatus.daysRemaining} days left
	{:else}
		Finished
	{/if}
</span>
