<script>
  import { user } from "$lib/flow/stores";
  import { logIn } from '$lib/flow/actions';

  import UserAddress from "$lib/components/UserAddress.svelte";
</script>

{#if !$user?.loggedIn}
<a role="button" href="/" class="contrast small-button" on:click|preventDefault={logIn}>Connect Wallet</a>
{:else}
<UserAddress address={$user?.addr} abbreviated={true}/>
{/if}