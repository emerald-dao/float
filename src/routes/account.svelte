<script>
  import { PAGE_TITLE_EXTENSION } from '$lib/constants'
  
  import AccountInfo from "$lib/components/account/AccountInfo.svelte";
  import Shared from '$lib/components/account/Shared.svelte';
  import Groups from '$lib/components/account/Groups.svelte';

  let tab = "account";
</script>
<svelte:head>
<title>Account {PAGE_TITLE_EXTENSION}</title>
</svelte:head>

<div class="container">
  <ul class="tabs">
    <li on:click|preventDefault={() => tab = "account"} class:selected="{tab === 'account'}">Your Account</li>
    <li on:click|preventDefault={() => tab = "shared"} class:selected="{tab === 'shared'}">Shared Minting</li>
    <li on:click|preventDefault={() => tab = "groups"} class:selected="{tab === 'groups'}">Groups</li>
  </ul>
  
  {#if tab === 'account'}
    <AccountInfo />
  {:else if tab === 'shared'}
    <Shared />
  {:else if tab === 'groups'}
    <Groups />
  {:else}
    <AccountInfo />
  {/if}
</div>

<style>
  .tabs {
    display: flex;
    justify-content: space-around;
  }

  .tabs li {
    list-style-type: none;
    font-size: 25px;
  }

  .selected {
    border-bottom: 2px solid var(--primary);
  }

  @media screen and (max-width: 700px) {
    .tabs {
      margin: 0px;
    }
    .tabs li {
      font-size: 15px;
    }
  }
</style>