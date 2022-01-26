<script>
  import { user } from "$lib/flow/stores";
  import { logIn, unauthenticate } from '$lib/flow/actions';
  import UserAddress from '$lib/components/UserAddress.svelte';
</script>
<svelte:head>
	<title>Account | Emerald FLOAT</title>
</svelte:head>

<div class="container">
	<h1>Your Account</h1>

  <div class="mt-2 mb-2">
  {#if !$user?.loggedIn}
  <button class="contrast small-button" on:click={logIn}>Connect Wallet</button>
  {:else}
  You are currently logged in as:
    <UserAddress address={$user?.addr}/>
    <br/>
    <a href="/" role="button" on:click|preventDefault={unauthenticate}>Logout</a>
    {/if}
  </div>
</div>

