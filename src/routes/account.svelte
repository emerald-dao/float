<script>
  import { user } from "$lib/flow/stores";
  import { authenticate, unauthenticate } from '$lib/flow/actions';
  import { PAGE_TITLE_EXTENSION } from '$lib/constants'
  
  import AccountContents from '$lib/components/AccountContents.svelte';
  import UserAddress from '$lib/components/UserAddress.svelte';
</script>
<svelte:head>
<title>Account {PAGE_TITLE_EXTENSION}</title>
</svelte:head>

<div class="container">
  <h1>Your Account</h1>
  
  <div class="mt-2 mb-2">
    {#if !$user?.loggedIn}
    <button class="contrast small-button" on:click={authenticate}>Connect Wallet</button>
    {:else}
    You are currently logged in as:
    <UserAddress address={$user?.addr}/>
    <br/>
    <a href="/" role="button" on:click|preventDefault={unauthenticate}>Logout</a>
    {/if}
  </div>
  
  {#if $user?.addr}
  <AccountContents address={$user.addr} />
  {/if}
</div>

