<script lang="ts">
	import getProfile from '$lib/utilities/profiles/getProfile';
	import Icon from '@iconify/svelte';

	export let address: string;
	export let inverse = false;
	export let isMedal = false;
</script>

{#await getProfile(address)}
	<div class="main-wrapper row align-center" class:inverse>
		<div class="creator-avatar" />
		<div class="profile-wrapper">
			<div class="line" />
			<span class="wallet-address w-regular off">
				{address}
			</span>
		</div>
	</div>
{:then profile}
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
{:catch error}
	<div class="main-wrapper row align-center" class:inverse>
		<img class="creator-avatar" src="/new-avatar.png" alt="Creator avatar" />
		<div class="profile-wrapper">
			<div class="profile-name-wrapper">
				<span class="profile-name"> Anonymus User </span>
			</div>
			<span class="wallet-address w-regular off">
				{address}
			</span>
		</div>
	</div>
{/await}

<style lang="scss">
	.main-wrapper {
		display: flex;
		flex-direction: row;
		gap: 0.5em;
		width: 100%;
		overflow: hidden;

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

		div.creator-avatar {
			background: var(--clr-background-secondary);
		}

		.profile-wrapper {
			display: flex;
			flex-direction: column;
			gap: 0.1em;
			overflow: hidden;
			width: 100%;

			.profile-name-wrapper {
				display: flex;
				flex-direction: row;
				gap: 0.2em;
				align-items: center;
				width: 100%;
			}

			.profile-name {
				font-size: 0.85em;
				color: var(--clr-heading-main);
				--font-weight: var(--font-weight-medium);
			}

			.line {
				width: 85%;
				height: 0.3em;
				margin-block: 0.4em;
				background: var(--clr-background-secondary);
				border-radius: 0.2em;
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
			overflow: hidden;
			text-overflow: ellipsis;
			white-space: nowrap;
			width: 100%;
		}
	}
</style>
