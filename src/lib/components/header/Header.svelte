<script>
  // import { page } from '$app/stores';
  import { user } from '$lib/flow/stores';
  import ConnectWallet from '$lib/components/ConnectWallet.svelte';
  import UserAddress from '../UserAddress.svelte';
  import { onMount } from 'svelte';
  import { resolver, theme } from '$lib/stores.js';
  import { fade, draw } from 'svelte/transition';
  import { resolveAddressObject } from '$lib/flow/actions';
  import { getResolvedName } from '$lib/flow/utils';

  let toggleTheme;

  onMount(() => {

    let html = document.querySelector('html')
    let currentDataTheme = html.getAttribute('data-theme');
    $theme = currentDataTheme || 'dark';

    if (!$theme && window?.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
      $theme = 'dark';
    } else {
      $theme = 'light';
    }

    toggleTheme = () => {
      let newTheme = $theme === 'light' ? 'dark' : 'light';
      html.setAttribute('data-theme', newTheme);
      $theme = newTheme;
      localStorage.setItem('theme', newTheme);
    }
  })

  async function initialize(address) {
    let addressObject = await resolveAddressObject(address);
    return getResolvedName(addressObject)
  }
  $: resolvedName = initialize($user?.addr || "");

  function toggleResolver() {
    if ($resolver === 'fn') {
      $resolver = 'find';
    } else {
      $resolver = 'fn';
    }
  }

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

  .resolver-toggle {
    padding: 5px;
    width: 60px;
    background-color: var(--primary-focus);
    display: inline-block;
    text-align: center;
    justify-content: center;
    display: flex;
    vertical-align: middle;
    align-items: center;
    color: var(--primary);
    font-weight: normal;
  }

  @media screen and (max-width: 500px) {
    img {
      max-width: 100px;
    }
    .float-logo {
      display: none;
    }
  }
</style>

<nav class="container">
  <ul class="float-logo">
    <li>
      <!-- when on mainnnet, replace this line with the one below-->
      <h1><a href="/"><img src="/logo-mainnet.png" alt="Emerald City FLOAT" /></a></h1>
      <!-- <h1><a href="/"><img src="/floatlogowebpage.png" alt="Emerald City FLOAT" /></a></h1> -->
    </li>
  </ul>
  <ul>
    
    <!-- <li><a href="/create" role="button" class="small-button" sveltekit:prefetch>+</a></li> -->
    <li>
      <a class="theme-toggle" href="/" on:click|preventDefault={toggleTheme}>
        {#if $theme === 'light'}
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-moon-fill" viewBox="0 0 16 16">
          <path in:draw="{{duration: 200}}" d="M6 .278a.768.768 0 0 1 .08.858 7.208 7.208 0 0 0-.878 3.46c0 4.021 3.278 7.277 7.318 7.277.527 0 1.04-.055 1.533-.16a.787.787 0 0 1 .81.316.733.733 0 0 1-.031.893A8.349 8.349 0 0 1 8.344 16C3.734 16 0 12.286 0 7.71 0 4.266 2.114 1.312 5.124.06A.752.752 0 0 1 6 .278z"/>
        </svg>
        {:else}
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-sun-fill" viewBox="0 0 16 16">
          <path in:draw="{{duration: 200}}" d="M8 12a4 4 0 1 0 0-8 4 4 0 0 0 0 8zM8 0a.5.5 0 0 1 .5.5v2a.5.5 0 0 1-1 0v-2A.5.5 0 0 1 8 0zm0 13a.5.5 0 0 1 .5.5v2a.5.5 0 0 1-1 0v-2A.5.5 0 0 1 8 13zm8-5a.5.5 0 0 1-.5.5h-2a.5.5 0 0 1 0-1h2a.5.5 0 0 1 .5.5zM3 8a.5.5 0 0 1-.5.5h-2a.5.5 0 0 1 0-1h2A.5.5 0 0 1 3 8zm10.657-5.657a.5.5 0 0 1 0 .707l-1.414 1.415a.5.5 0 1 1-.707-.708l1.414-1.414a.5.5 0 0 1 .707 0zm-9.193 9.193a.5.5 0 0 1 0 .707L3.05 13.657a.5.5 0 0 1-.707-.707l1.414-1.414a.5.5 0 0 1 .707 0zm9.193 2.121a.5.5 0 0 1-.707 0l-1.414-1.414a.5.5 0 0 1 .707-.707l1.414 1.414a.5.5 0 0 1 0 .707zM4.464 4.465a.5.5 0 0 1-.707 0L2.343 3.05a.5.5 0 1 1 .707-.707l1.414 1.414a.5.5 0 0 1 0 .708z"/>
        </svg>
        {/if}
      </a>
    </li>
    <li style="padding: 0px;">
      <button class="resolver-toggle" on:click|preventDefault={toggleResolver}>
        {#if $resolver === 'fn'}
          <span>.fn</span>
        {:else}
          <span>.find</span>
        {/if}
      </button>
    </li>
    <li>
      <a href="/about">About</a>
    </li>
    
    <li>
      {#await resolvedName then resolvedName}
      {#if $user?.loggedIn}
        <a href="/{resolvedName}" role="button" class="outline">
          <UserAddress address={$user?.addr} />
        </a>
      {:else}
        <ConnectWallet/>
      {/if}
    {/await}
    </li>
  </ul>
</nav>


