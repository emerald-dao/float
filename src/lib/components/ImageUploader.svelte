<script>
  import { onMount, createEventDispatcher } from "svelte";
  import { NFTStorage } from "nft.storage";

  const NFT_STORAGE_TOKEN = import.meta.env.VITE_NFT_STORAGE_ACCESS_TOKEN;
  const client = new NFTStorage({ token: NFT_STORAGE_TOKEN });

  /** event dispatch */
  const dispatch = createEventDispatcher();

  // ipfs uploading related
  let uploading = false;
  let uploadedSuccessfully = false;
  let imagePreviewSrc = null;

  let uploadToIPFS = async (e) => {
    uploading = true;
    uploadedSuccessfully = false;

    let file = e.target.files[0];

    const cid = await client.storeBlob(file);
    uploadedSuccessfully = true;
    uploading = false;
    imagePreviewSrc = `https://ipfs.io/ipfs/${cid}`;

    dispatch("ipfsAdded", cid);
  };
</script>

{#if !imagePreviewSrc}
  <label for="image">
    <slot>Image</slot>
    <input
      aria-busy={!!uploading}
      on:change={(e) => uploadToIPFS(e)}
      type="file"
      id="image"
      name="image"
      accept="image/png, image/gif, image/jpeg"
      disabled={uploading}
    />
    {#if uploading}
      <progress indeterminate />
    {/if}
  </label>
{/if}
{#if uploadedSuccessfully}
  <small>✓ Image uploaded successfully to IPFS!</small>
{/if}
{#if imagePreviewSrc}
  <h3>Preview</h3>
  <slot name="preview">
    <p>No Preview</p>
  </slot>
  <div class="mb-2" />
{/if}
