<script>
	import { hasFLOATCollectionSetUp, setupCollectionExecution } from '$flow/actions';
	import { Button } from '@emerald-dao/component-library';
	import { user } from '$stores/flow/FlowStore';

	let isSetup = false;

	async function checkSetup() {
		isSetup = await hasFLOATCollectionSetUp($user.addr);
	}

	async function setupCollection() {
		await setupCollectionExecution();
		isSetup = true;
	}
</script>

<section class="container-small center">
	{#if $user.loggedIn}
		{#await checkSetup() then blank}
			{#if isSetup}
				<Button on:click={setupCollection}>Setup Collection</Button>
			{:else}
				<p>Your collection is set up.</p>
			{/if}
		{/await}
	{:else}
		<p>Please log in.</p>
	{/if}
</section>
