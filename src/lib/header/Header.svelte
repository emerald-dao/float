<script>
  import { page } from '$app/stores';
  import ConnectWallet from '$lib/components/ConnectWallet.svelte';

  
</script>

<style>
  li {
    margin-right: 1rem;
  }

  h1 {
    font-size: 1.2rem;
  }
</style>

<nav class="container">
  <ul>
    <li>
      <h1><a href="/"><img style="width:1.2em; height:1.2em;" src="/floatlogo.png" alt="Emerald City FLOAT" /> FLOAT</a></h1>
    </li>
  </ul>
  <ul>
    
    <!-- <li><a href="/create" role="button" class="small-button" sveltekit:prefetch>+</a></li> -->
    <li class:active={$page.url.pathname === '/about'}><a href="/about" sveltekit:prefetch>About</a></li>
    <li><a href="/account"><ConnectWallet/></a></li>
  </ul>
</nav>


