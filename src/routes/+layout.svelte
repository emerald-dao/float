<script lang="ts">
	import '../app.postcss';
	import '@emerald-dao/design-system/build/variables-dark.css';
	import '@emerald-dao/design-system/build/variables-light.css';
	import '@emerald-dao/design-system/build/variables.css';
	import '@emerald-dao/component-library/styles/app.scss';
	import { Header, Footer } from '@emerald-dao/component-library';
	import { navElements, emeraldTools, socialMedia } from '$lib/config/navigation';
	import { user } from '$stores/flow/FlowStore';
	import { logIn, unauthenticate } from '$flow/actions';
	import { getFindProfile } from '$flow/utils';
	import { onMount } from 'svelte';
	import { page } from '$app/stores';

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
</script>

{#if route !== 'admin' || !($user && $user.addr)}
	<Header {logIn} {unauthenticate} {getFindProfile} user={$user} {navElements} />
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
