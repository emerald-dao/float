<script>
  import { user } from "$lib/flow/stores";
  import { authenticate, unauthenticate} from '$lib/flow/actions';
  
  import AccountContents from '$lib/components/AccountContents.svelte';
  import UserAddress from '$lib/components/UserAddress.svelte';
</script>

<div class="grid">
  <article>
    {#if !$user?.loggedIn}
      <button class="contrast small-button" on:click={authenticate}>Connect Wallet</button>
    {:else}
      <h2>You are currently logged in as:</h2>
      <UserAddress address={$user?.addr}/>
      <br/>
      <a class="logout" href="/" role="button" on:click|preventDefault={unauthenticate}>Logout</a>
    {/if}
  </article>
</div>

{#if $user?.addr}
  <AccountContents address={$user.addr} />
{/if} 

<style>
  .grid {
    text-align: center;
  }

  .logout {
    width: 300px;
  }
</style>