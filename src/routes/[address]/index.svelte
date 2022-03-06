<script>
  import { page } from "$app/stores";
  import Meta from "$lib/components/common/Meta.svelte";

  import Groups from "$lib/components/account/Groups.svelte";
  import Floats from "$lib/components/Floats.svelte";
  import Events from "$lib/components/Events.svelte";
  import { user } from "$lib/flow/stores";
  import Shared from "$lib/components/account/Shared.svelte";

  let tab = "floats";
</script>

<Meta
  title="FLOATs owned by {$page.params.address}"
  author={$page.params.address}
  description="FLOATs owned by {$page.params.address}"
  url={$page.url} />

<div class="container">
  <ul class="tabs">
    <li
      on:click|preventDefault={() => (tab = "floats")}
      class:selected={tab === "floats"}>
      FLOATs
    </li>
    <li
      on:click|preventDefault={() => (tab = "events")}
      class:selected={tab === "events"}>
      Events
    </li>
    <li
      on:click|preventDefault={() => (tab = "groups")}
      class:selected={tab === "groups"}>
      Groups
    </li>
    {#if $user?.addr == $page.params.address}
      <li
        on:click|preventDefault={() => (tab = "shared")}
        class:selected={tab === "shared"}>
        Share Account
      </li>
    {/if}
  </ul>

  {#if tab === "floats"}
    <Floats />
  {:else if tab === "events"}
    <Events />
  {:else if tab === "groups"}
    <Groups />
  {:else if tab === "shared"}
    <Shared />
  {:else}
    <Floats />
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

  @media screen and (max-width: 767px) {
    .tabs {
      margin: 0px;
    }
    .tabs li {
      font-size: 15px;
    }
  }
</style>
