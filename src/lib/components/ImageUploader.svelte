<script>
  import LibLoader from "$lib/components/LibLoader.svelte";
  import { onMount, createEventDispatcher } from "svelte";

  /** event dispatch */
  const dispatch = createEventDispatcher();

  /* States related to image upload */
  let ipfsIsReady = false;

  onMount(() => {
    ipfsIsReady = window?.IpfsHttpClient ?? false;
  });

  let ipfsReady = function () {
    console.log("ipfs is ready");
    ipfsIsReady = true;
  };

  // ipfs uploading related
  let uploading = false;
  let uploadingPercent = 0;
  let uploadedSuccessfully = false;
  let imagePreviewSrc = null;

  let uploadToIPFS = async (e) => {
    uploading = true;
    uploadingPercent = 0;
    uploadedSuccessfully = false;

    let file = e.target.files[0];

    function progress(len) {
      uploadingPercent = len / file.size;
    }

    const client = window.IpfsHttpClient.create({
      host: "ipfs.infura.io",
      port: 5001,
      protocol: "https",
    });

    const added = await client.add(file, { progress });
    /** @type {string} */
    const hash = added.path;

    uploadedSuccessfully = true;
    uploading = false;

    imagePreviewSrc = `https://cloudflare-ipfs.com/ipfs/${hash}`;

    dispatch("ipfsAdded", hash);
  };
</script>

<LibLoader
  url="https://cdn.jsdelivr.net/npm/ipfs-http-client@56.0.0/index.min.js"
  on:loaded={ipfsReady}
  uniqueId={+new Date()}
/>

{#if ipfsIsReady}
  <label for="image">
    <slot>Image</slot>
    <input
      aria-busy={!!uploading}
      on:change={(e) => uploadToIPFS(e)}
      type="file"
      id="image"
      name="image"
      accept="image/png, image/gif, image/jpeg"
    />
    {#if uploading}
      <progress value={uploadingPercent * 100} max="100" />
    {/if}

    {#if uploadedSuccessfully}
      <small>✓ Image uploaded successfully to IPFS!</small>
    {/if}
  </label>
{:else}
  <p>IPFS not loaded</p>
{/if}

{#if imagePreviewSrc}
  <h3>Preview</h3>
  <slot name="preview">
    <p>No Preview</p>
  </slot>
  <div class="mb-2" />
{/if}
