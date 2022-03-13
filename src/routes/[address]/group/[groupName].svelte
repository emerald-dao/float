<script>
  import { page } from "$app/stores";
  import Loading from "$lib/components/common/Loading.svelte";
  import Event from "$lib/components/Event.svelte";
  import Group from "$lib/components/Group.svelte";
  import { deleteGroup, getEventsInGroup, getGroup, resolveAddressObject } from "$lib/flow/actions";
  import { deleteGroupInProgress, deleteGroupStatus, user } from "$lib/flow/stores";

  let events;
  let group;
  async function initialize() {
    let addressObject = await resolveAddressObject($page.params.address); 
    events = await getEventsInGroup(addressObject.address, $page.params.groupName);
    group = await getGroup(addressObject.address, $page.params.groupName);
    return addressObject;
  }
  
  let addressObject = initialize();
</script>

{#await addressObject then addressObject}
  <Group
    name={group.name}
    description={group.description}
    imagePreviewSrc="https://ipfs.infura.io/ipfs/{group.image}"
    preview={true} />

  {#if $user?.addr == addressObject.address}
    {#if $deleteGroupInProgress}
      <button class="outline red" aria-busy="true" disabled>Deleting Group</button>
    {:else if $deleteGroupStatus.success}
      <button class="outline red" disabled>Group deleted successfully.</button>
    {:else if !$deleteGroupStatus.success && $deleteGroupStatus.error}
      <button class="outline red" disabled>
        {$deleteGroupStatus.error}
      </button>
    {:else}
      <button
        class="red outline"
        on:click|preventDefault={deleteGroup(
          $page.params.groupName
        )}>Delete Group</button>
    {/if}
  {/if}
{/await}

<div class="card-container">
  {#await addressObject}
    <Loading />
  {:then addressObject}
    {#each events as event}
      <Event
        floatEvent={{
          name: event.name,
          host: event.host,
          image: event.image,
          eventId: event.eventId,
        }} />
    {/each}
  {/await}
</div>

<style>
  .details {
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-direction: column;
  }
  .details p {
    margin: 0;
  }
  .details img {
    max-width: 200px;
    max-height: 100px;
  }

  @media screen and (max-width: 700px) {
    .grid h1 {
      font-size: 20px;
    }
  }
</style>
