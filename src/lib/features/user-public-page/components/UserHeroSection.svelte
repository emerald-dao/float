<script lang="ts">
	import type { User } from '$lib/types/user/user.interface';
	import Icon from '@iconify/svelte';

	export let userData: User;
	export let floatsClaimed: number;
	export let eventsCreated: number;
</script>

<section class="container-small">
	<img src={userData.image} alt="float" />
	<h1 class="medium">{userData.name}</h1>
	<div class="row-7">
		{#if userData.socialMedia}
			{#each Object.entries(userData.socialMedia) as mediaUrl}
				<div class="row media-wrapper">
					<Icon icon="tabler:brand-twitter" width="22" height="22" />
					<p>{mediaUrl}</p>
				</div>
			{/each}
		{/if}
	</div>
	<div class="stats-wrapper">
		<div>
			<p class="large">{floatsClaimed}</p>
			<p class="small">Floats Claimed</p>
		</div>
		<div>
			<p class="large">{eventsCreated}</p>
			<p class="small">Events Created</p>
		</div>
	</div>
</section>

<style type="scss">
	section {
		display: flex;
		flex-direction: column;
		justify-content: center;
		align-items: center;
		gap: var(--space-6);

		img {
			width: 260px;
			height: 260px;
			border-radius: 50%;
		}

		.media-wrapper {
			gap: var(--space-1);
			border: 1px solid var(--clr-border-primary);
			padding: var(--space-2) var(--space-3);
			border-radius: var(--radius-3);
		}

		.stats-wrapper {
			width: 100%;
			display: grid;
			grid-template-columns: repeat(2, 1fr);
			text-align: center;
			border-top: 1px dashed var(--clr-border-primary);
			border-bottom: 1px dashed var(--clr-border-primary);
			padding: var(--space-5) 0 var(--space-5) 0;
		}
	}
</style>
