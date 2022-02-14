<script>
  import CheckAddress from '$lib/components/CheckAddress.svelte';
  import { PAGE_TITLE_EXTENSION } from '$lib/constants';
</script>

<style>
  
  /* video {
    display:block;
    width:100%;
    max-width: 800px;
    margin: 20px auto;
  }
   */
  
  h1 {
    text-align:center;
  }

  .tag-line {
    font-weight: 300;
    font-size: 1.2rem;
    margin-top: 30px;
    display:block;
  }

  .island {
    width: 30vw;
    max-width: 400px;
  }
</style>

<svelte:head>
<title>Home {PAGE_TITLE_EXTENSION}</title>
</svelte:head>

<!-- <video autoplay muted loop id="myVideo">
  <source src="island.mp4" type="video/mp4" />
</video> -->

<div class="grid">
  <a href="/live">
    <div class="text-center">
      <img  class="island" src="/island.png" alt="FLOAT Logo" />
    </div>
  </a>
  <div class="mt-2 mb-2 text-center">
    <h1>Welcome to <br/> TestNet FLOAT</h1>
    <small>A service by <a href="https://discord.gg/emeraldcity" target="_blank"><img style="height:20px;width:auto;margin-right:4px;" src="/emeraldcitylogo.png" alt="Emerald Logo" />Emerald City DAO</a></small>
    <span class="tag-line">Unlock a unique identifier to show that you attended an event.</span>

    <div class="grid mt-2 no-break align-center">
      <a role="button" href="#findAddress" class="outline small-button mb-1">Find your event</a>
      <a role="button" href="/create" class="small-button mb-1">Create an event</a>
    </div>
  </div>
</div>

<article>
  <h2 id="findAddress">View FLOATs from an Address</h2>
  <CheckAddress />
</article>

