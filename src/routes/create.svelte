<script>
  import {
    user,
    eventCreationInProgress,
    eventCreatedStatus,
  } from "$lib/flow/stores";
  import {
    authenticate,
    createEvent,
    getGroups,
    isSharedWithUser,
  } from "$lib/flow/actions";

  import { draftFloat, theme } from "$lib/stores";
  import { PAGE_TITLE_EXTENSION } from "$lib/constants";
  import { notifications } from "$lib/notifications";

  import LibLoader from "$lib/components/LibLoader.svelte";
  import { onMount } from "svelte";
  import Float from "$lib/components/Float.svelte";
  import { distributeCode } from "$lib/flow/utils";
  import { slide } from "svelte/transition";
  import Loading from "$lib/components/common/Loading.svelte";

  let timezone = new Date()
    .toLocaleTimeString("en-us", { timeZoneName: "short" })
    .split(" ")[2];
  /* States related to image upload */
  let ipfsIsReady = false;
  let uploading = false;
  let uploadingPercent = 0;
  let uploadedSuccessfully = false;

  let imagePreviewSrc = null;

  let advancedOptions = false;

  onMount(() => {
    ipfsIsReady = window?.IpfsHttpClient ?? false;
  });

  let uploadToIPFS = async (e) => {
    uploading = true;
    uploadingPercent = 0;

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
    uploadedSuccessfully = true;
    uploading = false;
    const hash = added.path;
    $draftFloat.ipfsHash = hash;
    imagePreviewSrc = `https://ipfs.infura.io/ipfs/${hash}`;
  };

  function ipfsReady() {
    console.log("ipfs is ready");
    ipfsIsReady = true;
  }

  let minter = null;
  async function initCreateFloat() {
    // check if all required inputs are correct
    let canCreateFloat = await checkInputs();

    if (!canCreateFloat) {
      return;
    }

    createEvent(minter || $user?.addr, $draftFloat);
  }

  async function checkInputs() {
    let errorArray = [];
    let messageString = "The following mandatory fields are missing";

    // add conditions here
    if (!$draftFloat.name) {
      errorArray.push("Event Name");
    } else if (!$draftFloat.description) {
      errorArray.push("Event Description");
    } else if (!imagePreviewSrc) {
      errorArray.push("Event Image");
    }

    if (minter) {
      let canMintFor = await isSharedWithUser(minter, $user?.addr);
      if (!canMintFor) {
        messageString = "You cannot mint for";
        errorArray.push(minter);
      }
    }

    if (errorArray.length > 0) {
      notifications.info(`${messageString}: ${errorArray.join(",")}`);
      return false;
    } else {
      return true;
    }
  }
</script>

<svelte:head>
  <title>Create a new FLOAT {PAGE_TITLE_EXTENSION}</title>
</svelte:head>

<LibLoader
  url="https://cdn.jsdelivr.net/npm/ipfs-http-client@56.0.0/index.min.js"
  on:loaded={ipfsReady}
  uniqueId={+new Date()} />

<div class="container">
  <article>
    <h1 class="mb-1" style="text-align: center;">Create a new FLOAT</h1>

    <label for="name"
      >Event Name
      <input type="text" id="name" name="name" bind:value={$draftFloat.name} />
    </label>

    <label for="name"
      >Event URL
      <input type="text" id="name" name="name" bind:value={$draftFloat.url} />
    </label>

    <label for="description"
      >Event Description
      <textarea
        id="description"
        name="description"
        bind:value={$draftFloat.description} />
    </label>

    {#await getGroups($user?.addr)}
      <Loading />
    {:then groupsWeCanAddTo}
      {#if Object.keys(groupsWeCanAddTo).length > 0}
        <div class="input-group">
          <label for="groups">Add Event to Group</label>
          <div class="input-button-group" id="names" name="names">
            <select
              bind:value={$draftFloat.initialGroup}
              id="addToGroup"
              required>
              {#each Object.keys(groupsWeCanAddTo) as groupName}
                <option value={groupName}>{groupName}</option>
              {/each}
            </select>
          </div>
        </div>
      {/if}
    {/await}

    <br />

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
      <Float
        float={{
          eventName: $draftFloat.name,
          eventImage: $draftFloat.ipfsHash,
          totalSupply: "SERIAL_NUM",
          eventHost: $user?.addr || "0x0000000000",
        }} />
      <div class="mb-2" />
    {/if}

    <!-- 
      
      Claimable: Yes vs No (No = host must distribute manually, similar to custom above; Yes = quantity, time and claimcode appears)
      Quantity: UNLIMITED vs LIMITED (toggles FLOAT quantity limit input)
      Time: UNLIMITED vs LIMITED (toggles start /end time inputs)
      Requires Claim Code: Yes vs No (btw so are we going with hash or code after the event?) 
    -->
    <h3 class="mb-1">Configure your FLOAT</h3>

    <h5>Can be changed later.</h5>
    <!-- GIFTABLE -->
    <div class="grid no-break mb-1">
      <button
        class:secondary={!$draftFloat.transferrable}
        class="outline"
        on:click={() => ($draftFloat.transferrable = true)}>
        Gifting
        <span>This FLOAT can be gifted to other accounts on the FLOAT platform.</span>
      </button>
      <button
        class:secondary={$draftFloat.transferrable}
        class="outline"
        on:click={() => {
          $draftFloat.transferrable = false;
        }}>
        No Gifting
        <span>
          This FLOAT <strong>cannot</strong> be gifted to others on the FLOAT platform (can be transferred elsewhere).
        </span>
      </button>
    </div>

    <div class="grid no-break mb-1">
      <button
        class:secondary={!$draftFloat.claimable}
        class="outline"
        on:click={() => ($draftFloat.claimable = true)}>
        Claimable
        <span>
          Users can mint their own FLOAT based on the parameters defined below.
        </span>
      </button>
      <button
        class:secondary={$draftFloat.claimable}
        class="outline"
        on:click={() => ($draftFloat.claimable = false)}>
        Not Claimable
        <span
          >You will be responsible for distributing the FLOAT to accounts.</span>
      </button>
    </div>

    <!-- {#if !$draftFloat.claimable}
      <h5>This is how you would distribute your FLOAT to a user in Cadence:</h5>
      <xmp class={$theme === "light" ? "xmp-light" : "xmp-dark"}
        >{distributeCode}</xmp>
    {/if} -->

    <h5>Cannot be changed later.</h5>
    <!-- QUANTITY -->
    <div class="grid no-break mb-1">
      <button
        class:secondary={$draftFloat.quantity}
        class="outline"
        on:click={() => ($draftFloat.quantity = false)}>
        Unlimited Quantity
        <span
          >Select this if you don't want your FLOAT to have a limited quantity.</span>
      </button>
      <button
        class:secondary={!$draftFloat.quantity}
        class="outline"
        on:click={() => ($draftFloat.quantity = true)}>
        Limited Quantity
        <span
          >You can set the maximum number of times the FLOAT can be minted.</span>
      </button>
    </div>
    {#if $draftFloat.quantity}
      <label for="quantity"
        >How many can be claimed?
        <input
          type="number"
          name="quantity"
          bind:value={$draftFloat.quantity}
          min="1"
          placeholder="ex. 100" />
      </label>
      <hr />
    {/if}

    <!-- TIME -->
    <div class="grid no-break mb-1">
      <button
        class:secondary={$draftFloat.timelock}
        class="outline"
        on:click={() => ($draftFloat.timelock = false)}>
        No Time Limit
        <span>Can be minted at any point in the future.</span>
      </button>
      <button
        class:secondary={!$draftFloat.timelock}
        class="outline"
        on:click={() => ($draftFloat.timelock = true)}>
        Time Limit
        <span>Can only be minted between a specific time interval.</span>
      </button>
    </div>
    {#if $draftFloat.timelock}
      <div class="grid">
        <!-- Date -->
        <label for="start"
          >Start ({timezone})
          <input
            type="datetime-local"
            id="start"
            name="start"
            bind:value={$draftFloat.startTime} />
        </label>

        <!-- Date -->
        <label for="start"
          >End ({timezone})
          <input
            type="datetime-local"
            id="start"
            name="start"
            bind:value={$draftFloat.endTime} />
        </label>
      </div>
      <hr />
    {/if}

    <!-- SECRET -->
    <div class="grid no-break mb-1">
      <button
        class:secondary={$draftFloat.claimCodeEnabled}
        class="outline"
        on:click={() => ($draftFloat.claimCodeEnabled = false)}>
        Anyone Can Claim
        <span>Your FLOAT can be minted freely by anyone.</span>
      </button>
      <button
        class:secondary={!$draftFloat.claimCodeEnabled}
        class="outline"
        on:click={() => ($draftFloat.claimCodeEnabled = true)}>
        Use Secret Code(s)
        <span
          >Your FLOAT can only be minted if people know the secret code(s).</span>
      </button>
    </div>

    <!-- ONE SECRET OR MULTIPLE -->
    {#if $draftFloat.claimCodeEnabled}
      <div class="grid no-break mb-1">
        <button
          class:secondary={$draftFloat.multipleSecretsEnabled}
          class="outline"
          on:click={() => ($draftFloat.multipleSecretsEnabled = false)}>
          One Code for All
          <span>Use the same secret code for everyone.</span>
        </button>
        <button
          class:secondary={!$draftFloat.multipleSecretsEnabled}
          class="outline"
          on:click={() => ($draftFloat.multipleSecretsEnabled = true)}>
          Multiple Secret Codes
          <span
            >Specify a bunch of secret codes, each of which can only be used
            once.</span>
        </button>
      </div>
    {/if}
    {#if $draftFloat.claimCodeEnabled}
      <label for="claimCode"
        >{@html $draftFloat.multipleSecretsEnabled
          ? "Enter your codes, separated by a comma ( , )"
          : "Enter a claim code"} (<i>case-sensitive</i>)
        <input
          type="text"
          name="claimCode"
          bind:value={$draftFloat.claimCode}
          placeholder={$draftFloat.multipleSecretsEnabled
            ? "ex. code1, code2, code3, code4"
            : "ex. mySecretCode"} />
      </label>
      <hr />
    {/if}

    <!-- FLOWTOKEN PURCHASE -->
    <div class="grid no-break mb-1">
      <button
        class:secondary={$draftFloat.flowTokenPurchase}
        class="outline"
        on:click={() => ($draftFloat.flowTokenPurchase = false)}>
        Free
        <span>This FLOAT is free for users to claim.</span>
      </button>
      <button
        class:secondary={!$draftFloat.flowTokenPurchase}
        class="outline"
        on:click={() => {
          $draftFloat.flowTokenPurchase = true;
        }}>
        Payment
        <span>This FLOAT costs FlowToken to claim. Suitable for things like tickets.</span>
      </button>
    </div>
    {#if $draftFloat.flowTokenPurchase}
      <div class="grid">
        <!-- Date -->
        <label for="cost"
          >Cost (in FLOW)
          <input
            type="number"
            id="cost"
            name="cost"
            min="1.00"
            placeholder="ex. 100.0"
            step="0.01"
            bind:value={$draftFloat.flowTokenPurchase} />
            <small>Note: 5% of each purchase will go to the Emerald City DAO treasury.</small>
        </label>
      </div>
      <hr />
    {/if}

    {#if advancedOptions}
      <div transition:slide>
        <h4 class="">Create on behalf of another account (shared minting)</h4>
        <div class="input-button-group">
          <input
            placeholder="0x00000000000"
            type="text"
            id="minters"
            name="minters"
            bind:value={minter} />
        </div>
        <p class="small mt-1">
          Input an address to create an event as that account. This will only
          work if that account has given you shared minting rights.
        </p>
      </div>
    {/if}
    <button
      class="secondary outline text-center mt-2"
      on:click={() => (advancedOptions = !advancedOptions)}
      >{advancedOptions ? "Hide" : "Show"} advanced options</button>

    <footer>
      {#if !$user?.loggedIn}
        <div class="mt-2 mb-2">
          <button class="contrast small-button" on:click={authenticate}
            >Connect Wallet</button>
        </div>
      {:else if $eventCreationInProgress}
        <button aria-busy="true" disabled>Creating FLOAT</button>
      {:else if $eventCreatedStatus.success}
        <a
          role="button"
          class="d-block"
          href="/{$user.addr}/?tab=events"
          style="display:block">
          Event created successfully!
        </a>
      {:else if !$eventCreatedStatus.success && $eventCreatedStatus.error}
        <button class="error" disabled>
          {$eventCreatedStatus.error}
        </button>
      {:else}
        <button on:click|preventDefault={initCreateFloat}>Create FLOAT</button>
      {/if}
    </footer>
  </article>
</div>

<style>
  h4 {
    margin: 0;
  }
  .outline {
    text-align: left;
  }

  .outline span {
    display: block;
    font-size: 0.75rem;
    line-height: 1.2;
    font-weight: 400;
    opacity: 0.6;
  }

  .small {
    font-size: 0.75rem;
    line-height: 1.2;
  }

  /* .image-preview {
    max-width: 150px;
    height: auto;
  } */

  xmp {
    position: relative;
    width: 100%;
    font-size: 12px;
    padding: 10px;
    overflow: scroll;
    border-radius: 5px;
    color: white;
  }

  .xmp-dark {
    background: rgb(56, 232, 198, 0.25);
  }

  .xmp-light {
    background: rgb(27, 40, 50);
  }

  h5 {
    margin-bottom: 5px;
  }

  .error {
    background-color: red;
    border-color: white;
    color: white;
    opacity: 1;
  }
</style>
