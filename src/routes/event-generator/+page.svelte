<script lang="ts">
	import { logIn, unauthenticate } from '$flow/actions';
	import EventGenerator from '$lib/features/event-generator/EventGenerator.svelte';
	import { user } from '$stores/flow/FlowStore';
	import { ConnectWalletPage } from '@emerald-dao/component-library';
</script>

{#if $user && $user.addr}
	<EventGenerator />
{:else}
	<ConnectWalletPage user={$user} {logIn} {unauthenticate} />
{/if}
