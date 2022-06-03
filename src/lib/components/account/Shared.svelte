<script>
  import {
    addSharedMinterInProgress,
    addSharedMinterStatus,
    removeSharedMinterInProgress,
    setupAccountInProgress,
    setupAccountStatus,
    user,
  } from "$lib/flow/stores";
  import {
    addSharedMinter,
    getAllowed,
    isSetup,
    removeSharedMinter,
    setupAccount,
  } from "$lib/flow/actions";
  import UserAddress from "../UserAddress.svelte";
  import { authenticate, unauthenticate } from "@onflow/fcl";
  import CopyBadge from "$lib/components/common/CopyBadge.svelte";

  let newSharedMinter = "";

  let removeMinter = "";
  const loadAddresses = async () => {
    let addresses = await getAllowed($user?.addr);
    if (addresses?.length > 0) {
      removeMinter = addresses[0];
    }
    return addresses;
  };

  let sharedMinters = loadAddresses();
</script>

<article class="user-info">
  {#if !$user?.loggedIn}
    <button class="contrast small-button" on:click={authenticate}
      >Connect Wallet</button
    >
  {:else}
    <h2>Welcome to FLOAT</h2>
    <p class="mb-1 mt-2">You are currently logged in as</p>
    <div class="btn-group">
      <button class="outline mb-1">
        <CopyBadge text={$user?.addr}>
          <span class="mono">{$user?.addr}</span>
        </CopyBadge>
      </button>
      <button class="logout" on:click={unauthenticate}>Logout</button>
    </div>
    <br />
    {#await isSetup($user?.addr) then isSetup}
      {#if !isSetup}
        {#if $setupAccountInProgress}
          <button aria-busy="true" disabled>Setting up...</button>
        {:else if $setupAccountStatus.success}
          <button disabled>Successfully set up your account.</button>
        {:else if !$setupAccountStatus.success && $setupAccountStatus.error}
          <button class="error" disabled>
            {$setupAccountStatus.error}
          </button>
        {:else}
          <button disabled={$setupAccountInProgress} on:click={setupAccount}
            >Setup Account
          </button>
        {/if}
      {/if}
    {/await}
  {/if}
</article>

<!-- Add minters to your account so they can create FLOAT Events for you -->
<article>
  <header>
    <h3 class="text-center">Shared Minting</h3>
  </header>

  <p class="m-0 mb-1">
    Share this account with another address and allow them to create events on
    your behalf. Add an address below and click on "Add Shared Minter". Do at
    your own risk!
  </p>
  <label for="receiver m-0">
    <input
      class="m-0"
      type="text"
      name="receiver"
      bind:value={newSharedMinter}
      placeholder="0x00000000000"
    />
  </label>
  {#if $addSharedMinterInProgress}
    <button aria-busy="true" disabled>Adding...</button>
  {:else if $addSharedMinterStatus.success}
    <button disabled>Successfully added {newSharedMinter}</button>
  {:else if !$addSharedMinterStatus.success && $addSharedMinterStatus.error}
    <button class="error" disabled>
      {$addSharedMinterStatus.error}
    </button>
  {:else}
    <button
      disabled={$addSharedMinterInProgress}
      on:click={() => addSharedMinter(newSharedMinter)}
      >Add Shared Minter
    </button>
    <p class="text-center m-0 red">
      <small
        ><strong>BEWARE</strong>: Anyone with access to the address above will
        be able to control this account on FLOAT.</small
      >
    </p>
  {/if}
</article>

{#await sharedMinters then sharedMinters}
  {#if sharedMinters?.length > 0}
    <article>
      <label for="removeMinter">Accounts who share your account:</label>
      <select bind:value={removeMinter} id="removeMinter" required>
        {#each sharedMinters as minter}
          <option value={minter}>{minter}</option>
        {/each}
      </select>
      <button
        class="outline red"
        aria-busy={$removeSharedMinterInProgress}
        disabled={$removeSharedMinterInProgress}
        on:click={() => removeSharedMinter(removeMinter)}>Remove</button
      >
    </article>
  {/if}
{/await}

<style>
  .user-info {
    text-align: center;
    padding: 50px;
  }

  @media screen and (max-width: 410px) {
    .user-info {
      padding:50px 10px;
    }
  }

  .user-info h4 {
    display: inline-block;
    margin-bottom: 50px;
  }

  .user-info button {
    margin-left: 10px;
    display: inline;
    width: auto;
    padding: 10px;
    margin-bottom: 10px;
  }

  .logout {
    width: 200px;
  }

  @media screen and (max-width: 767px) {
    .user-info h4 {
      margin-bottom: 10px;
    }
  }
</style>
