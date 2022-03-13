<script>
  import Loading from "$lib/components/common/Loading.svelte";
  import Event from "$lib/components/Event.svelte";
  import EventsTable from "$lib/components/common/table/EventsTable.svelte";
  import { getEvents } from "$lib/flow/actions.js";
  import { user } from "$lib/flow/stores";
  export let addressObject;

  let floatEvents = async () => {
    const rawEvents = getEvents(addressObject.address);
    const formattedEvents = getEventsArray(rawEvents);
    return formattedEvents || [];
  }

  function getEventsArray(floatEventsObj) {
    if (floatEventsObj && Object.keys(floatEventsObj)?.length > 0) {
      console.log(floatEventsObj)
      return Object.values(floatEventsObj);
    } else {
      return [];
    }
  }
</script>

{#if $user?.addr == addressObject.address}
  <a href="/create" role="button" class="addnew">Create a new FLOAT Event</a>
{/if}


<article>
  <header>
    <h3 class="text-center">Events</h3>
  </header>
  {#await floatEvents()}
    <Loading />
  {:then floatEvents}
    {#if floatEvents.length > 10}
    <EventsTable {floatEvents} />
    {:else if floatEvents.length > 0}
    {#each getEventsArray(floatEvents) as floatEvent}
      <Event {floatEvent} />
    {/each}
    {:else}
    <p class="text-center">This account has not created any FLOAT events yet.</p>
    {/if}
  {/await}
</article>

<!-- <div class="card-container">
  {#await floatEvents}
    <Loading />
  {:then floatEvents}

    <EventsTable floatEvents={getEventsArray(floatEvents)} />

    {#if getEventsArray(floatEvents)?.length > 0}
      {#each getEventsArray(floatEvents) as floatEvent}
        <Event {floatEvent} />
      {/each}
    {:else}
      <p>This account has not created any Events yet.</p>
    {/if}
  {/await}
</div> -->

<style>
  .addnew {
    font-weight: bold;
    width: 100%;
  }

  @media screen and (max-width: 767px) {
    .addnew {
      margin-top: 20px;
    }
  }
</style>
