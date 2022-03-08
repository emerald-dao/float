<script>
  import { page } from "$app/stores";
  import Meta from "$lib/components/common/Meta.svelte";

  import Groups from "$lib/components/account/Groups.svelte";
  import Floats from "$lib/components/Floats.svelte";
  import Events from "$lib/components/Events.svelte";
  import { user } from "$lib/flow/stores";
  import Shared from "$lib/components/account/Shared.svelte";
  import { resolveAddressObject } from "$lib/flow/actions";
  import Loading from "$lib/components/common/Loading.svelte";

  let addressObject = resolveAddressObject($page.params.address);

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
      class:animatedlink={tab !== "floats"}
      class:selected={tab === "floats"}>
      FLOATs
    </li>
    <li
      on:click|preventDefault={() => (tab = "events")}
      class:animatedlink={tab !== "events"}
      class:selected={tab === "events"}>
      Events
    </li>
    <li
      on:click|preventDefault={() => (tab = "groups")}
      class:animatedlink={tab !== "groups"}
      class:selected={tab === "groups"}>
      Groups
    </li>
    {#await addressObject then addressObject}
      {#if $user?.addr == addressObject.address}
        <li
          on:click|preventDefault={() => (tab = "shared")}
          class:animatedlink={tab !== "shared"}
          class:selected={tab === "shared"}>
          Share Account
        </li>
      {/if}
    {/await}
  </ul>

  {#await addressObject}
    <Loading />
  {:then addressObject}
    {#if tab === "floats"}
      <Floats {addressObject} />
    {:else if tab === "events"}
      <Events {addressObject} />
    {:else if tab === "groups"}
      <Groups {addressObject} />
    {:else if tab === "shared"}
      <Shared />
    {:else}
      <Floats {addressObject} />
    {/if}
  {/await}
</div>

<style>

.animatedlink {
  display: inline-block;
  position: relative;
}

.animatedlink:after {
  content: '';
  position: absolute;
  width: 100%;
  transform: scaleX(0);
  height: 2px;
  bottom: 0;
  left: 0;
  background-color: var(--primary);
  transform-origin: bottom right;
  transition: transform 0.25s ease-out;
}

.animatedlink:hover:after {
  transform: scaleX(1);
  transform-origin: bottom left;
}

.selected {
  color: var(--primary);
  border-bottom: 2px solid var(--primary);
}

.tabs {
  display: flex;
  justify-content: space-around;
}

.tabs li {
  list-style-type: none;
  font-size: 18px;
  text-transform: uppercase;
  font-weight: bold;
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
