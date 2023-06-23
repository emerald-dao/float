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
	<div class="social-media">
		{#if userData.socialMedia}
			{#each Object.entries(userData.socialMedia) as mediaUrl}
				<a class="row media-wrapper" href={mediaUrl[1]} target="_blank">
					<Icon icon="tabler:brand-twitter" width="22" height="22" />
					<p>{[mediaUrl[0]]}</p>
				</a>
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

<style lang="scss">
	section {
		display: flex;
		flex-direction: column;
		justify-content: center;
		align-items: center;
		gap: var(--space-6);
		padding-block: 4rem 0;

		@include mq(small) {
			padding-block: 4rem;
		}

		img {
			width: 260px;
			height: 260px;
			border-radius: 50%;
		}

		.social-media {
			display: flex;
			flex-direction: column;
			gap: var(--space-2);

			@include mq(small) {
				flex-direction: row;
				gap: var(--space-7);
			}

			.media-wrapper {
				gap: var(--space-1);
				border: 1px solid var(--clr-border-primary);
				padding: var(--space-2) var(--space-3);
				border-radius: var(--radius-3);
				text-decoration: none;
				color: var(--clr-text-main);
			}
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
