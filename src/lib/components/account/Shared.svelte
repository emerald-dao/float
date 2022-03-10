<script>
  import { addSharedMinterInProgress, addSharedMinterStatus, removeSharedMinterInProgress, user } from "$lib/flow/stores";
  import { addSharedMinter, getAllowed, removeSharedMinter } from '$lib/flow/actions';
  import UserAddress from "../UserAddress.svelte";
  import { authenticate, unauthenticate } from "@samatech/onflow-fcl-esm";
  import CopyBadge from "$lib/components/common/CopyBadge.svelte";

  let newSharedMinter = "";
  
  let removeMinter = "";
  const loadAddresses = async () => {
    let addresses = await getAllowed($user?.addr);
    if (addresses?.length > 0) {
      removeMinter = addresses[0];
    }
    return addresses;
  }

  let sharedMinters = loadAddresses();
</script>

<article class="user-info">
  {#if !$user?.loggedIn}
    <button class="contrast small-button" on:click={authenticate}>Connect Wallet</button>
  {:else}
    <h4>You are logged in as: </h4>
    <button class="outline">
      <CopyBadge text={$user?.addr}>
        <span class="mono">{$user?.addr}</span>
      </CopyBadge>
    </button>
    <br/>
    <a class="logout" href="/" role="button" on:click|preventDefault={unauthenticate}>Logout</a>
  {/if}
</article>

<!-- Add minters to your account so they can create FLOAT Events for you -->
<article>
  <label for="receiver">
    Add a shared minter by copying the receiver's address below.<br /><br />
    <strong>BEWARE</strong>: This will allow this user to control your account on FLOAT.
    <input
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
      on:click={() =>
        addSharedMinter(newSharedMinter)}
      >Add Shared Minter
    </button>
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
      <button class="outline red" aria-busy={$removeSharedMinterInProgress} disabled={$removeSharedMinterInProgress} on:click={() => removeSharedMinter(removeMinter)}>Remove</button>
    </article>
  {/if}
{/await}

<style>
  .user-info {
    text-align: center;
    padding: 50px;
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