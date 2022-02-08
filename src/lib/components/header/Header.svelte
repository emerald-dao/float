<script>
  // import { page } from '$app/stores';
  import { user } from '$lib/flow/stores';
  import ConnectWallet from '$lib/components/ConnectWallet.svelte';
  import UserAddress from '../UserAddress.svelte';
  import { onMount } from 'svelte';
  import { theme } from '$lib/stores.js';

  let toggleTheme;

  onMount(() => {
    let html = document.querySelector('html')
    let currentTheme = html.getAttribute('data-theme');
    $theme = currentTheme;
    toggleTheme = () => {
      let newTheme = $theme === 'light' ? 'dark' : 'light';
      html.setAttribute('data-theme', newTheme);
      $theme = newTheme;
      localStorage.setItem('theme', newTheme);
    }
  })

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

  img {
    height: auto;
    max-width: 160px;
  }

  .theme-toggle {
    padding: 0;
    height: 45px;
    width: 45px;
    background-color: var(--primary-focus);
    border-radius: 50%;
    display: inline-block;
    text-align: center;
    justify-content: center;
    display: flex;
    vertical-align: middle;
    align-items: center;
  }
</style>

<nav class="container">
  <ul>
    <li>
      <h1><a href="/"><img src="/floatlogowebpage.png" alt="Emerald City FLOAT" /></a></h1>
    </li>
  </ul>
  <ul>
    
    <!-- <li><a href="/create" role="button" class="small-button" sveltekit:prefetch>+</a></li> -->
    <li>
      <a class="theme-toggle" href="/" on:click|preventDefault={toggleTheme}>
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-moon-fill" viewBox="0 0 16 16">
        <path d="M6 .278a.768.768 0 0 1 .08.858 7.208 7.208 0 0 0-.878 3.46c0 4.021 3.278 7.277 7.318 7.277.527 0 1.04-.055 1.533-.16a.787.787 0 0 1 .81.316.733.733 0 0 1-.031.893A8.349 8.349 0 0 1 8.344 16C3.734 16 0 12.286 0 7.71 0 4.266 2.114 1.312 5.124.06A.752.752 0 0 1 6 .278z"/>
      </svg>
    </a>
    </li>
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


