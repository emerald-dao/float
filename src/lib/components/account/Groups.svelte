<script>
  import { getGroups, createGroup } from "$lib/flow/actions";
  import { draftGroup } from "$lib/stores";
  import LibLoader from "../LibLoader.svelte";
  import { onMount } from "svelte";
  import Group from "../Group.svelte";
  import { addGroupInProgress, addGroupStatus, user } from "$lib/flow/stores";
  import { authenticate } from "@onflow/fcl";
  import { getResolvedName } from "$lib/flow/utils";
  export let addressObject;

  async function initialize() {
    return getResolvedName(addressObject);
  }

  let resolvedName = initialize();

  let ipfsIsReady = false;
  let uploading = false;
  let uploadingPercent = 0;
  let uploadedSuccessfully = false;

  let imagePreviewSrc = null;
  let open = false;

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

  let groups = getGroups(addressObject.address);
</script>

<LibLoader
  url="https://cdn.jsdelivr.net/npm/ipfs-http-client@56.0.0/index.min.js"
  on:loaded={ipfsReady}
  uniqueId={+new Date()} />

{#if $user?.addr === addressObject.address}
  {#if !open}
    <button on:click={() => (open = true)} class="create"
      >Create a new Group</button>
  {:else if open}
    <article>
      <header>
        <h3 class="m-0 text-center">Create a new Group</h3>
      </header>

      <label for="name"
        >Group Name
        <input
          type="text"
          id="name"
          name="name"
          bind:value={$draftGroup.name} />
      </label>

      <label for="description"
        >Group Description
        <textarea
          id="description"
          name="description"
          bind:value={$draftGroup.description} />
      </label>

      {#if ipfsIsReady}
        <label for="image"
          >Group Image
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
        <Group
          preview={true}
          name={$draftGroup.name}
          {imagePreviewSrc}
          description={$draftGroup.description} />
      {/if}

      {#if !$user?.loggedIn}
        <div class="mt-2 mb-2">
          <button class="contrast small-button" on:click={authenticate}
            >Connect Wallet</button>
        </div>
      {:else if $addGroupInProgress}
        <button aria-busy="true" disabled>Creating Group</button>
      {:else if $addGroupStatus.success}
        <button disabled>Group created successfully!</button>
      {:else if !$addGroupStatus.success && $addGroupStatus.error}
        <button class="error" disabled>
          {$addGroupStatus.error}
        </button>
      {:else}
        <button on:click|preventDefault={createGroup($draftGroup)}>
          Create Group
        </button>
      {/if}
    </article>
  {/if}
{/if}

<article>
  <header>
    <h3 class="text-center">Groups</h3>
  </header>
  {#await groups then groups}
    {#await resolvedName then resolvedName}
      {#if Object.keys(groups).length > 0}
        {#each Object.values(groups) as group}
          <Group
            {resolvedName}
            name={group.name}
            imagePreviewSrc={`https://ipfs.infura.io/ipfs/${group.image}`}
            description={group.description} />
        {/each}
      {:else}
        <p class="text-center no-margin">
          This account has not created any groups yet.
        </p>
      {/if}
    {/await}
  {/await}
</article>

<style>
  .create {
    margin-top: 20px;
  }
</style>
