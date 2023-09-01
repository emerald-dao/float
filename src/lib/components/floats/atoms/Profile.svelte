<script lang="ts">
	import type { Profile } from '$lib/types/user/profile.interface';
	import Icon from '@iconify/svelte';

	export let profile: Profile;
	export let inverse = false;
	export let isMedal = false;
</script>

<div class="main-wrapper row align-center" class:inverse>
	<img class="creator-avatar" src={profile.avatar} alt="Creator avatar" />
	<div class="profile-wrapper">
		<div class="profile-name-wrapper">
			<span class="profile-name">
				{profile.name}
			</span>
			{#if profile.type === 'find'}
				<Icon
					icon="tabler:discount-check-filled"
					width="0.78em"
					color={isMedal ? 'goldenrod' : 'var(--clr-primary-main)'}
				/>
			{/if}
		</div>
		<span class="wallet-address w-regular off">
			{profile.address}
		</span>
	</div>
</div>

<style lang="scss">
	.main-wrapper {
		display: flex;
		flex-direction: row;
		gap: 0.5em;

		&.inverse {
			flex-direction: row-reverse;

			.profile-wrapper {
				align-items: flex-end;
			}
		}

		.creator-avatar {
			width: 2em;
			height: 2em;
			border-radius: 50%;
			object-fit: cover;
			object-position: center;
		}

		.profile-wrapper {
			display: flex;
			flex-direction: column;
			gap: 0.1em;

			.profile-name-wrapper {
				display: flex;
				flex-direction: row;
				gap: 0.2em;
				align-items: center;
			}

			.profile-name {
				font-size: 0.85em;
				color: var(--clr-heading-main);
				--font-weight: var(--font-weight-medium);
			}

			.wallet-address {
				font-family: var(--font-mono);
				font-size: 0.67em;
			}
		}

		.off {
			color: var(--clr-text-off);
		}

		span {
			line-height: 1.3em;
		}
	}
</style>
