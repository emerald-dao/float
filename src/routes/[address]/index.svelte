<script>
  import { t } from "svelte-i18n";
  import { page } from "$app/stores";
  import Meta from "$lib/components/common/Meta.svelte";

  import Challenges from "$lib/components/Challenges.svelte";
  import Groups from "$lib/components/account/Groups.svelte";
  import Floats from "$lib/components/Floats.svelte";
  import Events from "$lib/components/Events.svelte";
  import { user } from "$lib/flow/stores";
  import Shared from "$lib/components/account/Shared.svelte";
  import { resolveAddressObject } from "$lib/flow/actions";
  import Loading from "$lib/components/common/Loading.svelte";
  import { goto } from "$app/navigation";

  $: addressObject = resolveAddressObject($page.params.address);

  $: tab = $page.url.searchParams.get("tab") || "floats";
  let query = new URLSearchParams($page.url.searchParams.toString());
</script>

<Meta
  title={$t("common.headmeta.title-floats", {
    values: { address: $page.params.address },
  })}
  author={$page.params.address}
  description={$t("common.headmeta.title-floats", {
    values: { address: $page.params.address },
  })}
  url={$page.url}
/>

<div class="">
  <ul class="tabs">
    <li
      on:click={function () {
        query.set("tab", "floats");
        goto(`?${query.toString()}`);
      }}
      class:animatedlink={tab !== "floats"}
      class:selected={tab === "floats"}
    >
      {$t("common.main.floats")}
    </li>
    <li
      on:click={function () {
        query.set("tab", "events");
        goto(`?${query.toString()}`);
      }}
      class:animatedlink={tab !== "events"}
      class:selected={tab === "events"}
    >
      {$t("common.main.events")}
    </li>
    <li
      on:click={function () {
        query.set("tab", "groups");
        goto(`?${query.toString()}`);
      }}
      class:animatedlink={tab !== "groups"}
      class:selected={tab === "groups"}
    >
      {$t("common.main.groups")}
    </li>
    <li
      on:click={function () {
        query.set("tab", "challenges");
        goto(`?${query.toString()}`);
      }}
      class:animatedlink={tab !== "challenges"}
      class:selected={tab === "challenges"}
    >
      {$t("common.main.challenges")}
    </li>
    {#await addressObject then addressObject}
      {#if $user?.addr == addressObject.address}
        <li
          on:click={function () {
            query.set("tab", "account");
            goto(`?${query.toString()}`);
          }}
          class:animatedlink={tab !== "account"}
          class:selected={tab === "account"}
        >
          {$t("common.main.account")}
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
    {:else if tab === "challenges"}
      <Challenges {addressObject} />
    {:else if tab === "account"}
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
    content: "";
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
    margin-bottom: 5px;
  }

  .tabs li {
    list-style-type: none;
    font-size: 18px;
    text-transform: uppercase;
    font-weight: bold;
    cursor: pointer;
    padding: 0px 10px;
  }

  .tabs li.selected {
    cursor: default;
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
