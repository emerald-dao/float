<script>
  import { onMount } from "svelte";

  import { PAGE_TITLE_EXTENSION } from "$lib/constants";
  import LibLoader from "$lib/components/LibLoader.svelte";

  let timezone = new Date()
    .toLocaleTimeString("en-us", { timeZoneName: "short" })
    .split(" ")[2];
  /* States related to image upload */
  let ipfsIsReady = false;

  onMount(() => {
    ipfsIsReady = window?.IpfsHttpClient ?? false;
  });

  function ipfsReady() {
    console.log("ipfs is ready");
    ipfsIsReady = true;
  }
</script>

<svelte:head>
  <title>Create a new FLOAT Series {PAGE_TITLE_EXTENSION}</title>
</svelte:head>

<LibLoader
  url="https://cdn.jsdelivr.net/npm/ipfs-http-client@56.0.0/index.min.js"
  on:loaded={ipfsReady}
  uniqueId={+new Date()}
/>
