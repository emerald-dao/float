<script>
  import { page } from "$app/stores";
  import CopyBadge from "$lib/components/common/CopyBadge.svelte";
  import Loading from "$lib/components/common/Loading.svelte";
  import EventsTable from "$lib/components/common/table/EventsTable.svelte";
  import {
    deleteGroup,
    getEventsInGroup,
    getGroup,
    resolveAddressObject,
  } from "$lib/flow/actions";
  import {
    deleteGroupInProgress,
    deleteGroupStatus,
    user,
  } from "$lib/flow/stores";

  let events;
  let group;
  async function initialize() {
    let addressObject = await resolveAddressObject($page.params.address);
    events = await getEventsInGroup(
      addressObject.address,
      $page.params.groupName
    );
    group = await getGroup(addressObject.address, $page.params.groupName);
    return addressObject;
  }

  let addressObject = initialize();
</script>

{#await addressObject}
  <Loading />
{:then addressObject}
  <article>
    <header class="text-center">
      <h3>{group.name}</h3>
      <p class="no-margin">{group.description}</p>
    </header>

    <EventsTable floatEvents={events} />

    <footer>
      <blockquote>
        <strong><small class="muted">PASTE INTO DISCORD</small></strong><br />
        <div class="command-badge mono" data-tooltip="Paste into Discord">
          <svg
            data-svg-carbon-icon="LogoDiscord24"
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 32 32"
            fill="currentColor"
            width="24"
            height="24"
            preserveAspectRatio="xMidYMid meet"
          >
            <path
              d="M13.647,14.907a1.4482,1.4482,0,1,0,1.326,1.443A1.385,1.385,0,0,0,13.647,14.907Zm4.745,0a1.4482,1.4482,0,1,0,1.326,1.443A1.385,1.385,0,0,0,18.392,14.907Z"
            /><path
              d="M24.71,4H7.29A2.6714,2.6714,0,0,0,4.625,6.678V24.254A2.6714,2.6714,0,0,0,7.29,26.932H22.032l-.689-2.405,1.664,1.547L24.58,27.53,27.375,30V6.678A2.6714,2.6714,0,0,0,24.71,4ZM19.692,20.978s-.468-.559-.858-1.053a4.1021,4.1021,0,0,0,2.353-1.547,7.4391,7.4391,0,0,1-1.495.767,8.5564,8.5564,0,0,1-1.885.559,9.1068,9.1068,0,0,1-3.367-.013,10.9127,10.9127,0,0,1-1.911-.559,7.6184,7.6184,0,0,1-.949-.442c-.039-.026-.078-.039-.117-.065a.18.18,0,0,1-.052-.039c-.234-.13-.364-.221-.364-.221a4.0432,4.0432,0,0,0,2.275,1.534c-.39.494-.871,1.079-.871,1.079a4.7134,4.7134,0,0,1-3.965-1.976,17.409,17.409,0,0,1,1.872-7.579,6.4285,6.4285,0,0,1,3.653-1.365l.13.156a8.77,8.77,0,0,0-3.419,1.703s.286-.156.767-.377a9.7625,9.7625,0,0,1,2.951-.819,1.2808,1.2808,0,0,1,.221-.026,11,11,0,0,1,2.626-.026A10.5971,10.5971,0,0,1,21.2,11.917a8.6518,8.6518,0,0,0-3.237-1.651l.182-.208a6.4285,6.4285,0,0,1,3.653,1.365,17.409,17.409,0,0,1,1.872,7.579A4.752,4.752,0,0,1,19.692,20.978Z"
            />
          </svg>
          <span class="command">/groupverifier {$page.params.address} {group.name}</span
          >
        </div>
        <CopyBadge
          text={`/groupverifier creator:${$page.params.address} groupname:${group.name} role:`}
        />
      </blockquote>
      {#if $user?.addr == addressObject.address}
        {#if $deleteGroupInProgress}
          <button class="outline red" aria-busy="true" disabled
            >Deleting Group</button
          >
        {:else if $deleteGroupStatus.success}
          <button class="outline red" disabled
            >Group deleted successfully.</button
          >
        {:else if !$deleteGroupStatus.success && $deleteGroupStatus.error}
          <button class="outline red" disabled>
            {$deleteGroupStatus.error}
          </button>
        {:else}
          <button
            class="red outline"
            on:click|preventDefault={deleteGroup($page.params.groupName)}
            >Delete Group</button
          >
        {/if}
      {/if}
    </footer>
  </article>
{/await}

<style>
  small {
    font-size: 13px;
    margin-left: 10px;
  }
</style>
