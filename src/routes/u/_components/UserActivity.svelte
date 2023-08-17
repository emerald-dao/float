<script lang="ts">
	import type { GroupWithFloatsIds } from '$lib/features/groups/types/group.interface';
	import type { FLOAT } from '$lib/types/float/float.interface';
	import type { Profile } from '$lib/types/user/profile.interface';
	import CardAndTicketToggle from './atoms/CardAndTicketToggle.svelte';
	import UserCollection from './sections/UserCollection.svelte';

	export let floats: FLOAT[];
	export let userProfile: Profile;
	export let groups: GroupWithFloatsIds[];

	let viewMode: 'cards' | 'tickets' = 'tickets';
</script>

<section>
	<div class="header-wrapper">
		<div class="container-medium">
			<div class="profile-wrapper">
				<img src={userProfile.avatar} alt="user avatar" />
				<p class="large">{userProfile.name}</p>
			</div>
			<h4 class="h5">Collection</h4>
			<div class="right-wrapper row-4">
				<p class="small">{`${floats.length} FLOATs`}</p>
				<CardAndTicketToggle bind:viewMode />
			</div>
		</div>
	</div>
	<div class="container">
		<UserCollection {floats} {groups} bind:viewMode />
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
		}

		.profile-wrapper {
			display: flex;
			flex-direction: row;
			align-items: center;
			gap: var(--space-4);

			img {
				width: 47px;
				height: 47px;
				border-radius: 50%;
			}

			p {
				color: var(--clr-heading-main);
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
