<script lang="ts">
	import { transactionStore } from '$lib/stores/flow/TransactionStore';
	import { profile } from '$lib/stores/flow/FlowStore';
	import '../app.postcss';
	import '@emerald-dao/design-system/build/variables-dark.css';
	import '@emerald-dao/design-system/build/variables-light.css';
	import '@emerald-dao/design-system/build/variables.css';
	import '@emerald-dao/component-library/styles/app.scss';
	import { Header, Footer, TransactionModal } from '@emerald-dao/component-library';
	import {
		navElements,
		emeraldTools,
		socialMedia,
		avatarDropDownNavigation
	} from '$lib/config/navigation';
	import { user } from '$stores/flow/FlowStore';
	import { logIn, unauthenticate } from '$flow/actions';
	import { getFindProfile } from '$flow/utils';
	import { onMount } from 'svelte';
	import { page } from '$app/stores';
	import getProfile from '$lib/utilities/profiles/getProfile';
	import Icon from '@iconify/svelte';
	import UserSearchBar from '$lib/features/bulk-distribute-floats/components/atoms/searchBar/UserSearchBar.svelte';
	import { goto } from '$app/navigation';

	let route: string | null;

	let addressInputValue: string;
	let validUserInSearchbar: boolean;

	function extractFirstSegment(route: string): string | null {
		const regex = /^\/([^\/]+)/;
		const matches = route.match(regex);
		if (matches && matches.length === 2) {
			return matches[1];
		}
		return null;
	}

	$: route = typeof $page.route.id === 'string' ? extractFirstSegment($page.route.id) : null;

	onMount(() => {
		let html = document.querySelector('html');

		if (html) {
			html.setAttribute('data-theme', 'light');
		}
	});

	const connectProfileToStore = async (address: string) => {
		$profile = await getProfile(address);
	};

	$: if ($user.addr) {
		connectProfileToStore($user.addr);
	} else {
		$profile = null;
	}
</script>

<TransactionModal
	transactionInProgress={$transactionStore.progress}
	transactionStatus={$transactionStore.transaction}
	on:close={() => transactionStore.resetTransaction()}
/>
{#if (route !== 'admin' && route !== 'embed') || !($user && $user.addr)}
	<Header
		{logIn}
		{unauthenticate}
		{getFindProfile}
		user={$user}
		{navElements}
		logoText="FLOAT"
		userAvatar={$profile?.avatar}
		userName={$profile?.name}
		width="full"
		{avatarDropDownNavigation}
	>
		<div slot="commands" class="commands-wrapper row-3">
			<form
				on:submit|preventDefault={() => {
					if (validUserInSearchbar) {
						goto(`/u/${addressInputValue}`);
						addressInputValue = '';
					}
				}}
			>
				<UserSearchBar
					bind:addressInputValue
					bind:validUser={validUserInSearchbar}
					buttonText="Profile"
					fontSize="0.9rem"
					autoSelectKey="/"
					placeholder={`Search user by address or .find name`}
					dropdownMode={true}
				/>
			</form>
			{#if $user.loggedIn}
				<a href="/event-generator">
					<Icon icon="tabler:plus" />
					Create event
				</a>
			{/if}
		</div>
	</Header>
{:else}
	<div />
{/if}

<main>
	<slot />
</main>

{#if route === null || route === 'discover'}
	<Footer {navElements} {emeraldTools} socials={socialMedia} />
{/if}

<style lang="scss">
	main {
		display: flex;
		flex-direction: column;
		overflow-x: hidden;
	}

	.commands-wrapper {
		a {
			border: none;
			background-color: var(--clr-neutral-badge);
			border-radius: var(--radius-1);
			display: flex;
			align-items: center;
			gap: var(--space-1);
			font-size: var(--font-size-0);
			padding: var(--space-1) var(--space-3);
			color: var(--clr-heading-main);
			cursor: pointer;
			text-decoration: none;
		}
	}
</style>
