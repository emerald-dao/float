<script>
  import { addSharedMinterInProgress, addSharedMinterStatus, removeSharedMinterInProgress, user } from "$lib/flow/stores";
  import { addSharedMinter, authenticate, unauthenticate, getAllowed, removeSharedMinter } from '$lib/flow/actions';
  import { PAGE_TITLE_EXTENSION } from '$lib/constants'
  
  import AccountContents from '$lib/components/AccountContents.svelte';
  import UserAddress from '$lib/components/UserAddress.svelte';

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
<svelte:head>
<title>Account {PAGE_TITLE_EXTENSION}</title>
</svelte:head>

<div class="container">
  <h1>Your Account</h1>
  
  <div class="grid">
    <article>
      {#if !$user?.loggedIn}
        <button class="contrast small-button" on:click={authenticate}>Connect Wallet</button>
      {:else}
        You are currently logged in as:
        <UserAddress address={$user?.addr}/>
        <br/>
        <a href="/" role="button" on:click|preventDefault={unauthenticate}>Logout</a>
        <br />
        <br />

        <label for="removeMinter">Accounts who can mint for you:</label>
        
          {#await sharedMinters then sharedMinters}
            {#if sharedMinters?.length > 0}
              <select bind:value={removeMinter} id="removeMinter" required>
                {#each sharedMinters as minter}
                  <option value={minter}>{minter}</option>
                {/each}
              </select>
              <button class="outline red" aria-busy={$removeSharedMinterInProgress} disabled={$removeSharedMinterInProgress} on:click={() => removeSharedMinter(removeMinter)}>Remove</button>
            {:else}
              <p>None</p>
            {/if}
          {/await}
      {/if}
    </article>
  
    {#if $user?.loggedIn}
      <!-- Add minters to your account so they can create FLOAT Events for you -->
      <article>
        <label for="receiver">
          Add a shared minter by copying the receiver's address below.<br /><br />
          <strong>BEWARE</strong>: This will allow this user to create FLOAT Events for you.
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
    {/if}
  </div>
  
  {#if $user?.addr}
  <AccountContents address={$user.addr} />
  {/if} 
</div>

<style>
  .remove {
    
  }
</style>