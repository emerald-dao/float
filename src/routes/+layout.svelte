<script lang="ts">
	import { transactionStore } from '$lib/stores/flow/TransactionStore';
	import { profile } from '$lib/stores/flow/FlowStore';
	import '../app.postcss';
	import '@emerald-dao/design-system/build/variables-dark.css';
	import '@emerald-dao/design-system/build/variables-light.css';
	import '@emerald-dao/design-system/build/variables.css';
	import '@emerald-dao/component-library/styles/app.scss';
	import { Header, Footer, TransactionModal } from '@emerald-dao/component-library';
	import { navElements, emeraldTools, socialMedia } from '$lib/config/navigation';
	import { user } from '$stores/flow/FlowStore';
	import { logIn, unauthenticate } from '$flow/actions';
	import { getFindProfile } from '$flow/utils';
	import { onMount } from 'svelte';
	import { page } from '$app/stores';
	import getProfile from '$lib/utilities/profiles/getProfile';

	let route: string | null;

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
{#if route !== 'admin' || !($user && $user.addr)}
	<Header
		{logIn}
		{unauthenticate}
		{getFindProfile}
		user={$user}
		{navElements}
		logoText="FLOAT"
		userAvatar={$profile?.avatar}
		userName={$profile?.name}
	/>
{:else}
	<div />
{/if}

<main>
	<slot />
</main>

{#if route === null}
	<Footer {navElements} {emeraldTools} socials={socialMedia} />
{/if}

<style lang="scss">
	main {
		display: flex;
		flex-direction: column;
	}
</style>
