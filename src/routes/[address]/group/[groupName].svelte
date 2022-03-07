<script>
  import { page } from "$app/stores";
  import Loading from "$lib/components/common/Loading.svelte";
  import Event from "$lib/components/Event.svelte";
  import Group from "$lib/components/Group.svelte";
  import { deleteGroup, getEventsInGroup, getGroup } from "$lib/flow/actions";
  import { deleteGroupInProgress, deleteGroupStatus, user } from "$lib/flow/stores";

  let events = getEventsInGroup($page.params.address, $page.params.groupName);
  let group = getGroup($page.params.address, $page.params.groupName);
</script>

{#await group then group}
  <Group
    name={group.name}
    description={group.description}
    imagePreviewSrc="https://ipfs.infura.io/ipfs/{group.image}"
    preview={true} />
{/await}

{#if $user?.addr == $page.params.address}
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
        $page.params.address,
        $page.params.groupName
      )}>Delete Group</button>
  {/if}
{/if}

<div class="card-container">
  {#await events}
    <Loading />
  {:then events}
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
