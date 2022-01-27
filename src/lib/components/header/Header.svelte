<script>
  // import { page } from '$app/stores';
  import { user } from '$lib/flow/stores';
  import ConnectWallet from '$lib/components/ConnectWallet.svelte';
  import UserAddress from '../UserAddress.svelte';
</script>

<style>
  li {
    margin-right: 1rem;
  }
  
  h1 {
    font-size: 1.2rem;
  }
  
  .outline {
    padding: 6px 14px;
  }
</style>

<nav class="container">
  <ul>
    <li>
      <h1><a href="/"><img style="width:auto;height:2rem;" src="/floatlogotype.png" alt="Emerald City FLOAT" /></a></h1>
    </li>
  </ul>
  <ul>
    
    <!-- <li><a href="/create" role="button" class="small-button" sveltekit:prefetch>+</a></li> -->
    <li><a href="/about">About</a></li>
    
    <li>
      {#if $user?.loggedIn}
      <a href="/account" role="button" class="outline">
        <UserAddress address={$user?.addr || '0x0'} abbreviated={true}/>
      </a>
      {:else}
      <ConnectWallet/>
      {/if}
    </li>
  </ul>
</nav>


