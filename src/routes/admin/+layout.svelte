<script lang="ts">
	import { user } from '$stores/flow/FlowStore';
	import { logIn, unauthenticate } from '$flow/actions';
	import AdminHeader from './_components/navigation/AdminHeader.svelte';
	import '@emerald-dao/component-library/styles/app.scss';
	import AdminNavMobile from './_components/navigation/AdminNavMobile.svelte';
	import AdminNavDesktop from './_components/navigation/AdminNavDesktop.svelte';
	import { ConnectWalletPage } from '@emerald-dao/component-library';
</script>

{#if $user && $user.addr}
	<div class="main-wrapper">
		<AdminHeader />
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
