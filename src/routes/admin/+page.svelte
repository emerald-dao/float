<script lang="ts">
	import { goto } from '$app/navigation';
	import { unauthenticate, logIn } from '$flow/actions';
	import { user } from '$stores/flow/FlowStore';
	import { ConnectWalletPage } from '@emerald-dao/component-library';

	$: if ($user.addr) {
		goto(`/admin/${$user.addr}/events`);
	}
</script>

{#if !$user.addr}
	<ConnectWalletPage user={$user} {logIn} {unauthenticate} />
{/if}
