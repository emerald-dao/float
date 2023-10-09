<script lang="ts">
	import Profile from '$lib/components/floats/atoms/Profile/Profile.svelte';
	import type { GroupWithFloatsIds } from '$lib/features/groups/types/group.interface';
	import type { EventWithStatus } from '$lib/types/event/event.interface';
	import type { FLOAT } from '$lib/types/float/float.interface';
	import type { Profile } from '$lib/types/user/profile.interface';
	import CardAndTicketToggle from './atoms/CardAndTicketToggle.svelte';
	import FloatsAndEventsToggle from './atoms/FloatsAndEventsToggle.svelte';
	import UserEventsCollection from './sections/UserEventsCollection.svelte';
	import UserFloatsCollection from './sections/UserFloatsCollection.svelte';

	export let floats: FLOAT[];
	export let events: EventWithStatus[];
	export let userProfile: Profile;
	export let groups: GroupWithFloatsIds[];

	let viewMode: 'cards' | 'tickets' = 'tickets';
	let floatsOrEventsView: 'floats' | 'events' = 'floats';
</script>

<section>
	<div class="header-wrapper">
		<div class="container-medium">
			<Profile address={userProfile.address} />
			<div class="row-3">
				<FloatsAndEventsToggle bind:floatsOrEventsView />
			</div>
			<div class="right-wrapper row-4">
				{#if floatsOrEventsView === 'floats'}
					<p class="small">{`${floats.length} FLOATs`}</p>
				{:else if floatsOrEventsView === 'events'}
					<p class="small">{`${events.length} Events`}</p>
				{/if}
				<CardAndTicketToggle bind:viewMode />
			</div>
		</div>
	</div>
	<div class="container">
		{#if floatsOrEventsView === 'floats'}
			<UserFloatsCollection {floats} {groups} bind:viewMode />
		{:else if floatsOrEventsView === 'events'}
			<UserEventsCollection {events} bind:viewMode />
		{/if}
	</div>
</section>

<style lang="scss">
	section {
		padding-block: 0;
		background-color: var(--clr-background-primary);

		@include mq(small) {
			padding-block: 4rem;
		}
	}

	.header-wrapper {
		display: none;

		@include mq(small) {
			display: flex;
			position: sticky;
			top: 0;
			z-index: 999;
			margin-top: var(--space-6);
			background-color: var(--clr-background-primary);
		}

		.container-medium {
			display: grid;
			grid-template-columns: repeat(3, 1fr);
			justify-content: center;
			align-items: center;
			text-align: center;
			padding: var(--space-3) 0;

			.row-3 {
				align-items: center;
				justify-content: center;
			}
		}

		.right-wrapper {
			text-align: right;
			display: flex;
			align-items: center;
			justify-content: flex-end;
		}
	}
</style>
