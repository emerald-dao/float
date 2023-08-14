<script lang="ts">
	import Blur from '$lib/components/Blur.svelte';
	import type { Profile } from '$lib/types/user/profile.interface';
	import { Label } from '@emerald-dao/component-library';
	import Icon from '@iconify/svelte';
	import { getUserOverallLevel } from '../_features/badges/functions/getUserBadges';
	import UserBadge from '../_features/badges/components/atoms/UserBadge.svelte';
	import { USER_OVERALL_BADGE } from '../_features/badges/userBadges';

	export let userProfile: Profile;
	export let floatsClaimed: number;
	export let eventsCreated: number;

	let flip: boolean = false;

	const userOverallLevel = getUserOverallLevel(floatsClaimed, eventsCreated);
</script>

<section class="container">
	<Blur color="tertiary" right="22%" top="10%" />
	<Blur left="22%" top="30%" />
	<div
		class="secondary-wrapper"
		role="button"
		tabindex="0"
		on:click={() => (flip = !flip)}
		on:keydown
		class:flip
		class:inverse-flip={flip}
	>
		<div class="image-front">
			<img src={userProfile.avatar} alt="float" />
		</div>
		<div class="image-back">
			{#if userOverallLevel === 0}
				<UserBadge
					badgeLevel={USER_OVERALL_BADGE[0].levels[0]}
					noLevel={true}
					levelNumber={userOverallLevel}
					userOverallBadge={true}
				/>
			{:else}
				<UserBadge
					badgeLevel={USER_OVERALL_BADGE[0].levels[userOverallLevel - 1]}
					levelNumber={userOverallLevel}
					nextLevelGoal={USER_OVERALL_BADGE[0].levels[userOverallLevel]
						? USER_OVERALL_BADGE[0].levels[userOverallLevel].goal
						: undefined}
					userOverallBadge={true}
				/>
			{/if}
		</div>
	</div>
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

		.secondary-wrapper {
			position: relative;
			width: 260px;
			height: 260px;
			perspective: 1000px;
			cursor: pointer;

			.image-front,
			.image-back {
				position: absolute;
				width: 100%;
				height: 100%;
				-webkit-backface-visibility: hidden; /* Safari */
				backface-visibility: hidden;
				transition: transform 0.5s ease;
				display: flex;
				justify-content: center;
				align-items: center;
			}
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

		.image-front {
			transform: rotateY(0deg);
		}

		.image-back {
			transform: rotateY(180deg);
		}

		.inverse-flip .image-front {
			transform: rotateY(180deg);
		}

		.inverse-flip .image-back {
			transform: rotateY(0deg);
		}
	}
</style>
