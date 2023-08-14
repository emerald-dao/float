<script lang="ts">
	import { user } from '$stores/flow/FlowStore';
	import { page } from '$app/stores';
	import { logIn, unauthenticate } from '$flow/actions';
	import AdminHeader from './_components/navigation/AdminHeader.svelte';
	import '@emerald-dao/component-library/styles/app.scss';
	import AdminNavMobile from './_components/navigation/AdminNavMobile.svelte';
	import AdminNavDesktop from './_components/navigation/AdminNavDesktop.svelte';
	import { ConnectWalletPage } from '@emerald-dao/component-library';

	export let data;

	let route: string | null;

	console.log($page);

	function extractSecondPart(route: string): string | null {
		const regex = /^\/\w+\/([^\/]+)(?:\/|$)/;
		const matches = route.match(regex);
		if (matches && matches.length === 2) {
			return matches[1];
		}
		return null;
	}

	$: route = typeof $page.route.id === 'string' ? extractSecondPart($page.route.id) : null;
</script>

{#if $user && $user.addr}
	<div class="main-wrapper">
		<AdminHeader {route} userName={data.user.name} userAvatar={data.user.avatar} />
		<div class="secondary-wrapper">
			<AdminNavMobile />
			<AdminNavDesktop />
			<slot />
		</div>
	</div>
{:else}
	<ConnectWalletPage user={$user} {logIn} {unauthenticate} />
{/if}

<style lang="scss">
	.main-wrapper {
		@include mq(medium) {
			max-height: 100vh;
			flex: 1;
			display: flex;
			flex-direction: column;
		}

		.secondary-wrapper {
			display: flex;
			flex-direction: column;
			flex: 1;
			overflow: hidden;

			@include mq(medium) {
				display: grid;
				grid-template-columns: 1fr 4fr;
			}
		}
	}
</style>
