<script>
  import { getGroups, createGroup, deleteGroup } from '$lib/flow/actions';
  import { draftGroup } from '$lib/stores';
  import LibLoader from '../LibLoader.svelte';
  import {onMount} from 'svelte';
  import Group from '../Group.svelte';
  import { user } from '$lib/flow/stores';

  let ipfsIsReady = false;
  let uploading = false;
  let uploadingPercent = 0;
  let uploadedSuccessfully = false;

  let imagePreviewSrc = null;

  onMount(() => {
    ipfsIsReady = window?.IpfsHttpClient ?? false;
  });

  let uploadToIPFS = async (e) => {
    uploading = true;
    uploadingPercent = 0;

    // imagePreviewSrc = e.target.files[0]
    let file = e.target.files[0];

    function progress(len) {
      uploadingPercent = len / file.size;
    }
    console.log("uploading");

    const client = window.IpfsHttpClient.create({
      host: "ipfs.infura.io",
      port: 5001,
      protocol: "https",
    });

    console.log(file);
    const added = await client.add(file, { progress });
    uploadedSuccessfully = true;
    uploading = false;
    const hash = added.path;
    $draftGroup.ipfsHash = hash;
    imagePreviewSrc = `https://ipfs.infura.io/ipfs/${hash}`;
  };

  function ipfsReady() {
    console.log("ipfs is ready");
    ipfsIsReady = true;
  }

  let groups = getGroups($user?.addr);
  console.log(groups);

</script>

<LibLoader
  url="https://cdn.jsdelivr.net/npm/ipfs-http-client@56.0.0/index.min.js"
  on:loaded={ipfsReady}
  uniqueId={+new Date()} />

<article class="create">
  <h4>Create a new Group</h4>

  <label for="name"
      >Event Name
      <input type="text" id="name" name="name" bind:value={$draftGroup.name} />
    </label>

    <label for="description"
      >Event Description
      <textarea
        id="description"
        name="description"
        bind:value={$draftGroup.description} />
    </label>

    {#if ipfsIsReady}
      <label for="image"
        >Event Image
        <input
          aria-busy={!!uploading}
          on:change={(e) => uploadToIPFS(e)}
          type="file"
          id="image"
          name="image"
          accept="image/png, image/gif, image/jpeg" />
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
      <Group preview={true} name={$draftGroup.name} {imagePreviewSrc} description={$draftGroup.description} />
    {/if}

    <button on:click|preventDefault={createGroup(null, $draftGroup)}>Create Group</button>
</article>

{#await groups then groups}
  <h1>List of groups:</h1>
  {#each Object.values(groups) as group}
    <Group name={group.name} imagePreviewSrc={`https://ipfs.infura.io/ipfs/${group.image}`} description={group.description} />
  {/each}
{/await}

<style>
  .create {
  }
</style>