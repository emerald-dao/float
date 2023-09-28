<script context="module">
  import "$lib/i18n";
  import { waitLocale } from "svelte-i18n";

  export async function load() {
    await waitLocale();
    return {};
  }
</script>

<script>
  import Header from "$lib/components/header/Header.svelte";
  import Transaction from "$lib/components/common/Transaction.svelte";
  import Notifications from "$lib/components/common/Notifications.svelte";

  import "../app.css";
  import { onMount } from "svelte";
  import { page } from "$app/stores";
  import { resolver } from "$lib/stores.js";
  import Meta from "$lib/components/common/Meta.svelte";
  import banner from "$lib/banner.js";
  import Banner from "$lib/components/Banner.svelte";

  onMount(() => {
    let savedTheme = localStorage.getItem("theme");
    if (savedTheme) {
      console.log("retrieving saved theme preference");
      let html = document.querySelector("html");
      html.setAttribute("data-theme", savedTheme);
    }
  });

  function toggleResolver() {
    if ($resolver === "fn") {
      $resolver = "find";
    } else {
      $resolver = "fn";
    }
  }

  console.log($page.url.pathname);
</script>

{#if banner.enabled}
  <Banner time={banner.time} isScheduled={banner.isScheduled} />
{/if}

<Meta
  title={$page.stuff.title}
  author={$page.stuff.author}
  description={$page.stuff.description}
  url={$page.stuff.url}
  image={$page.stuff.image}
  removeTitleSuffix={$page.stuff.removeTitleSuffix} />

<Header />

<!-- Locale loading -->
<h1>
  We are upgrading FLOAT to v2, so this website will be down for an hour or so.
  We apologize for the inconveniance, but know it will be worth it ;)
</h1>

<style>
  .graffle {
    position: relative;
    display: flex;
    justify-content: center;
    align-items: center;
  }

  img.graffle {
    position: relative;
    top: -5px;
    width: 100px;
    height: auto;
    margin-left: 5px;
  }

  footer {
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    text-align: center;
    padding: 10px;
  }

  p {
    font-size: 0.7rem;
  }

  footer a {
    font-weight: bold;
  }

  @media (min-width: 480px) {
    footer {
      padding: 10px 0;
    }
  }

  .resolver-toggle {
    padding: 3px 8px;
    font-size: 0.5rem;
    background-color: var(--primary-focus);
    text-align: center;
    display: inline-block;
    vertical-align: middle;
    align-items: center;
    color: var(--primary);
    font-weight: normal;
    width: auto;
  }
</style>
