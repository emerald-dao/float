<script lang="ts">
	import type { User } from '$lib/types/user/user.interface';
	import Icon from '@iconify/svelte';
	import { getUserOverallLevel } from '../_features/badges/functions/getUserBadges';
	import UserBadge from '../_features/badges/components/atoms/UserBadge.svelte';
	import { USER_OVERALL_BADGE } from '../_features/badges/userBadges';

	export let userData: User;
	export let floatsClaimed: number;
	export let eventsCreated: number;

	let flip: boolean = false;

	const userOverallLevel = getUserOverallLevel(floatsClaimed, eventsCreated);
</script>

<section class="container-small">
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
			<img src={userData.image} alt="float" />
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
	<h1 class="medium">{userData.name}</h1>
	<div class="social-media">
		{#if userData.socialMedia}
			{#each Object.entries(userData.socialMedia) as mediaUrl}
				<a class="row media-wrapper" href={mediaUrl[1]} target="_blank">
					<Icon icon="tabler:brand-twitter" />
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
				justify-content: center;
				align-items: center;
				gap: var(--space-1);
				border: 1px solid var(--clr-border-primary);
				padding: 6px 10px;
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
			padding: var(--space-5) 0 0 0;
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
