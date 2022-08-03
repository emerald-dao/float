<script>
  // import { page } from '$app/stores';
  import { user } from "$lib/flow/stores";
  import ConnectWallet from "$lib/components/ConnectWallet.svelte";
  import UserAddress from "../UserAddress.svelte";
  import { onMount } from "svelte";
  import { theme } from "$lib/stores.js";
  import { fade, draw } from "svelte/transition";
  import { resolveAddressObject } from "$lib/flow/actions";
  import { getResolvedName } from "$lib/flow/utils";

  let toggleTheme;

  onMount(() => {
    let html = document.querySelector("html");
    html.setAttribute("data-theme", $theme);

    toggleTheme = () => {
      let newTheme = $theme === "light" ? "dark" : "light";
      $theme = newTheme;
      html.setAttribute("data-theme", $theme);
    };
  });

  async function initialize(address) {
    let addressObject = await resolveAddressObject(address);
    return getResolvedName(addressObject);
  }
  $: resolvedName = initialize($user?.addr || "");
</script>

<nav>
  <ul>
    <li>
      <!-- when on mainnnet, replace this line with the one below-->
      <h1>
        <a href="/"
          ><img src="/floatlogowebpage.png" alt="Emerald City FLOAT" /></a>
      </h1>
      <!-- <h1><a href="/"><img src="/floatlogowebpage.png" alt="Emerald City FLOAT" /></a></h1> -->
    </li>
    <li>
      <a class="theme-toggle" href="/" on:click|preventDefault={toggleTheme}>
        {#if $theme === "light"}
          <svg
            xmlns="http://www.w3.org/2000/svg"
            width="16"
            height="16"
            fill="currentColor"
            class="bi bi-moon-fill"
            viewBox="0 0 16 16">
            <path
              in:draw={{ duration: 200 }}
              d="M6 .278a.768.768 0 0 1 .08.858 7.208 7.208 0 0 0-.878 3.46c0 4.021 3.278 7.277 7.318 7.277.527 0 1.04-.055 1.533-.16a.787.787 0 0 1 .81.316.733.733 0 0 1-.031.893A8.349 8.349 0 0 1 8.344 16C3.734 16 0 12.286 0 7.71 0 4.266 2.114 1.312 5.124.06A.752.752 0 0 1 6 .278z" />
          </svg>
        {:else}
          <svg
            xmlns="http://www.w3.org/2000/svg"
            width="16"
            height="16"
            fill="currentColor"
            class="bi bi-sun-fill"
            viewBox="0 0 16 16">
            <path
              in:draw={{ duration: 200 }}
              d="M8 12a4 4 0 1 0 0-8 4 4 0 0 0 0 8zM8 0a.5.5 0 0 1 .5.5v2a.5.5 0 0 1-1 0v-2A.5.5 0 0 1 8 0zm0 13a.5.5 0 0 1 .5.5v2a.5.5 0 0 1-1 0v-2A.5.5 0 0 1 8 13zm8-5a.5.5 0 0 1-.5.5h-2a.5.5 0 0 1 0-1h2a.5.5 0 0 1 .5.5zM3 8a.5.5 0 0 1-.5.5h-2a.5.5 0 0 1 0-1h2A.5.5 0 0 1 3 8zm10.657-5.657a.5.5 0 0 1 0 .707l-1.414 1.415a.5.5 0 1 1-.707-.708l1.414-1.414a.5.5 0 0 1 .707 0zm-9.193 9.193a.5.5 0 0 1 0 .707L3.05 13.657a.5.5 0 0 1-.707-.707l1.414-1.414a.5.5 0 0 1 .707 0zm9.193 2.121a.5.5 0 0 1-.707 0l-1.414-1.414a.5.5 0 0 1 .707-.707l1.414 1.414a.5.5 0 0 1 0 .707zM4.464 4.465a.5.5 0 0 1-.707 0L2.343 3.05a.5.5 0 1 1 .707-.707l1.414 1.414a.5.5 0 0 1 0 .708z" />
          </svg>
        {/if}
      </a>
    </li>

    <!-- <li>
      <a href="/about">About</a>
    </li> -->
  </ul>
  <ul class="text-center">
    <!-- <li><a href="/create" role="button" class="small-button" sveltekit:prefetch>+</a></li> -->

    <li class="block">
      {#await resolvedName then resolvedName}
        {#if $user?.loggedIn}
          <a href="/{resolvedName}?tab=account" role="button" class="outline">
            <UserAddress address={$user?.addr} />
          </a>
        {:else}
          <ConnectWallet />
        {/if}
      {/await}
    </li>
  </ul>
</nav>

<style>
  nav {
    background-color: var(--card-background-color);
    height: 10vh;
    box-shadow: var(--card-box-shadow);
    margin-bottom: 20px;
  }
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

  ul {
    display: flex;
    text-align: center;
    margin: 0 auto;
    align-items: center;
  }

  @media screen and (max-width: 500px) {
    img {
      max-width: 100px;
    }
  }

  @media screen and (max-width: 780px) {
    nav li:last-child {
      margin: 0;
    }

    li h1 a {
      padding: 0;
    }
  }
</style>
