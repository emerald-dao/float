<script lang="ts">
	import Blur from '$lib/components/Blur.svelte';
	import type { Profile } from '$lib/types/user/profile.interface';
	import { Label } from '@emerald-dao/component-library';
	import Icon from '@iconify/svelte';

	export let userProfile: Profile;
	export let floatsClaimed: number;
	export let eventsCreated: number;
</script>

<section class="container">
	<Blur color="tertiary" right="22%" top="10%" />
	<Blur left="22%" top="30%" />
	<img src={userProfile.avatar} alt="float" />
	<h1>{userProfile.name}</h1>
	<Label color="transparent" size="small">
		<Icon icon="tabler:wallet" />
		{userProfile.address}
	</Label>
	<!-- <div class="social-media">
		{#if userProfile.socialMedia}
			{#each Object.entries(userProfile.socialMedia) as mediaUrl}
				<a class="row media-wrapper" href={mediaUrl[1]} target="_blank">
					<Icon icon="tabler:brand-twitter" />
					<p>{[mediaUrl[0]]}</p>
				</a>
			{/each}
		{/if}
	</div> -->
	<div class="stats-wrapper">
		<div>
			<p class="h5 w-medium">{floatsClaimed}</p>
			<p class="small">Floats Claimed</p>
		</div>
		<div>
			<p class="h5 w-medium">{eventsCreated}</p>
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
		gap: var(--space-4);
		padding-block: 4rem 0;
		border-bottom: 1px dashed var(--clr-border-primary);

		@include mq(small) {
			padding-block: 4rem;
		}

		h1 {
			margin-bottom: var(--space-2);
		}

		img {
			width: 220px;
			height: 220px;
			border-radius: 50%;
			box-shadow: 0px 6px 15px 10px var(--clr-shadow-primary);
		}

		// .social-media {
		// 	display: flex;
		// 	flex-direction: column;
		// 	gap: var(--space-2);

		// 	@include mq(small) {
		// 		flex-direction: row;
		// 		margin-top: var(--space-4);
		// 		gap: var(--space-6);
		// 	}

		// 	.media-wrapper {
		// 		justify-content: center;
		// 		align-items: center;
		// 		gap: var(--space-2);
		// 		border: 1px solid var(--clr-border-primary);
		// 		padding: var(--space-1) var(--space-4);
		// 		border-radius: var(--radius-3);
		// 		text-decoration: none;
		// 		color: var(--clr-text-main);
		// 	}
		// }

		.stats-wrapper {
			width: 100%;
			display: flex;
			text-align: center;
			justify-content: center;
			gap: var(--space-12);
			padding: var(--space-12) 0 0 0;

			p {
				color: var(--clr-text-main);
			}
		}
	}
</style>
