<script lang="ts">
	import Blur from '$lib/components/Blur.svelte';
	import type { Profile } from '$lib/types/user/profile.interface';
	import { Label } from '@emerald-dao/component-library';
	import Icon from '@iconify/svelte';
	import {
		getUserAllFloatsBadge,
		getUserEventBadge,
		getUserFloatsBadges,
		getUserOverallLevel
	} from '../_features/badges/functions/getUserBadges';
	import UserBadge from '../_features/badges/components/UserBadge.svelte';
	import {
		USER_EVENT_BADGE,
		USER_FLOAT_BADGES,
		USER_OVERALL_BADGE,
		TOTAL_FLOATS_BADGE
	} from '../_features/badges/userBadges';
	import type { FLOAT } from '$lib/types/float/float.interface';
	import type { Event } from '$lib/types/event/event.interface';

	export let userProfile: Profile;

	export let userFloats: FLOAT[];
	export let userEvents: Event[];

	const userEventLevel = getUserEventBadge(userEvents);
	const userFloatsLevels = getUserFloatsBadges(userFloats);
	const userAllFloatsLevel = getUserAllFloatsBadge(userFloats);
	const userOverallLevel = getUserOverallLevel(userFloats.length, userEvents.length);

	let flip: boolean = false;
</script>

<section class="container">
	<Blur color="tertiary" right="22%" top="10%" />
	<Blur left="22%" top="30%" />
	<div class="avatar-and-badges-wrapper">
		<div class="badge-wrapper badge-one">
			<UserBadge
				badgeLevel={USER_EVENT_BADGE.levels[userEventLevel === 0 ? 0 : userEventLevel - 1]}
				level={userEventLevel}
				nextLevelGoal={USER_EVENT_BADGE.levels[userEventLevel]
					? USER_EVENT_BADGE.levels[userEventLevel].goal
					: undefined}
				imageWidth="100px"
			/>
		</div>
		<div
			class="avatar-wrapper"
			role="button"
			tabindex="0"
			on:mouseenter={() => (flip = true)}
			on:mouseleave={() => (flip = false)}
			on:keydown
			class:flip
			class:inverse-flip={flip}
		>
			<div class="image-front">
				<img src={userProfile.avatar} alt="float" />
			</div>
			<div class="image-back" class:opacity40={userOverallLevel === 0}>
				<img
					src={USER_OVERALL_BADGE.levels[userOverallLevel === 0 ? 0 : userOverallLevel - 1].image}
					alt="User overall level"
				/>
			</div>
		</div>
		<div class="badge-wrapper badge-two">
			<UserBadge
				badgeLevel={TOTAL_FLOATS_BADGE.levels[
					userAllFloatsLevel === 0 ? 0 : userAllFloatsLevel - 1
				]}
				level={userAllFloatsLevel}
				nextLevelGoal={TOTAL_FLOATS_BADGE.levels[userAllFloatsLevel]
					? TOTAL_FLOATS_BADGE.levels[userAllFloatsLevel].goal
					: undefined}
				imageWidth="100px"
			/>
		</div>
	</div>
	<h1>{userProfile.name}</h1>
	<Label color="transparent" size="small">
		<Icon icon="tabler:wallet" />
		{userProfile.address}
	</Label>
	<div class="column-10">
		<div class="stats-wrapper">
			<div>
				<p class="h5 w-medium">{userFloats.length}</p>
				<p class="small">Floats Claimed</p>
			</div>
			<div>
				<p class="h5 w-medium">{userEvents.length}</p>
				<p class="small">Events Created</p>
			</div>
		</div>
		<div class="row-8 badges-wrapper">
			{#each userFloatsLevels as level, i}
				<UserBadge
					badgeLevel={USER_FLOAT_BADGES[i].levels[level === 0 ? 0 : level - 1]}
					{level}
					nextLevelGoal={USER_FLOAT_BADGES[i].levels[level]
						? USER_FLOAT_BADGES[i].levels[level].goal
						: undefined}
				/>
			{/each}
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

		.avatar-and-badges-wrapper {
			display: grid;
			grid-auto-columns: 1fr;
			grid-template-columns: 50% 50%;
			grid-template-rows: auto auto;
			gap: 0px 0px;
			grid-template-areas:
				'avatar avatar'
				'badge-one badge-two';
			justify-content: center;

			@include mq(small) {
				display: flex;
				flex-direction: row;
				align-items: center;
				gap: var(--space-4);
			}

			.avatar-wrapper {
				width: 260px;
				height: 260px;
				perspective: 1000px;
				grid-area: avatar;

				.image-front,
				.image-back {
					position: absolute;
					width: 100%;
					height: 100%;
					-webkit-backface-visibility: hidden; /* Safari */
					backface-visibility: hidden;
					transition: transform 0.3s ease-in-out;
					display: flex;
					justify-content: center;
					align-items: center;
				}
			}

			.badge-wrapper {
				display: flex;
				justify-content: center;

				&.badge-one {
					grid-area: badge-one;
				}

				&.badge-two {
					grid-area: badge-two;
				}
			}
		}

		h1 {
			margin-bottom: var(--space-2);
			text-align: center;
		}

		img {
			width: 220px;
			height: 220px;
			border-radius: 50%;
			box-shadow: 0px 6px 15px 10px var(--clr-shadow-primary);
		}

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

	.badges-wrapper {
		flex-wrap: wrap;
		padding-bottom: var(--space-7);
		align-items: center;
		justify-content: center;
	}

	.opacity40 {
		opacity: 0.4;
	}
</style>
