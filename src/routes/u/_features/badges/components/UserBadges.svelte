<script lang="ts">
	import { getUserEventsBadges, getUserFloatsBadges } from '../functions/getUserBadges';
	import { USER_EVENT_BADGES, USER_FLOAT_BADGES } from '../userBadges';
	import UserBadge from './atoms/UserBadge.svelte';
	import type { FLOAT } from '$lib/types/float/float.interface';
	import type { Event } from '$lib/types/event/event.interface';

	export let userFloats: FLOAT[];
	export let userEvents: Event[];

	const userEventsLevels = getUserEventsBadges(userEvents);
	const userFloatsLevels = getUserFloatsBadges(userFloats);
</script>

<div class="main-wrapper">
	<h5>Badges</h5>
	<div class="badges-wrapper">
		{#each userEventsLevels as level, i}
			{#if level === 0}
				<UserBadge badgeLevel={USER_EVENT_BADGES[i].levels[0]} noLevel={true} levelNumber={level} />
			{:else}
				<UserBadge
					badgeLevel={USER_EVENT_BADGES[i].levels[level - 1]}
					levelNumber={level}
					nextLevelGoal={USER_EVENT_BADGES[i].levels[level]
						? USER_EVENT_BADGES[i].levels[level].goal
						: undefined}
				/>
			{/if}
		{/each}
		{#each userFloatsLevels as level, i}
			{#if level === 0}
				<UserBadge badgeLevel={USER_FLOAT_BADGES[i].levels[0]} noLevel={true} levelNumber={level} />
			{:else}
				<UserBadge
					badgeLevel={USER_FLOAT_BADGES[i].levels[level - 1]}
					levelNumber={level}
					nextLevelGoal={USER_FLOAT_BADGES[i].levels[level]
						? USER_FLOAT_BADGES[i].levels[level].goal
						: undefined}
				/>
			{/if}
		{/each}
	</div>
</div>

<style lang="scss">
	.main-wrapper {
		display: none;
		padding-bottom: 2rem;

		@include mq(small) {
			display: flex;
			flex-direction: column;
			gap: var(--space-4);
		}

		@include mq(medium) {
			gap: var(--space-6);
		}

		.badges-wrapper {
			display: flex;
			flex-direction: row;
			gap: var(--space-3);
			flex-wrap: wrap;
		}
	}
</style>
