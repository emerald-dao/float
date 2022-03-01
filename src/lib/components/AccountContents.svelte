<script>
  import Loading from '$lib/components/common/Loading.svelte';
  import Float from '$lib/components/Float.svelte';
  import Event from '$lib/components/Event.svelte';
  import { getEvents, getFLOATs } from '$lib/flow/actions.js'
  
  export let address;
  
  let floatEvents = getEvents(address);
  let floats = getFLOATs(address);
  
  function getEventsArray(floatEventsObj) {
    if(floatEventsObj && Object.keys(floatEventsObj)?.length > 0) {
      return Object.values(floatEventsObj);
    } else {
      return []
    }
  }
</script>

<h3>Claimed FLOATs</h3>

<div class="card-container">
  {#await floats}
  <Loading />
  {:then floats} 
    {#if floats?.length > 0}
      {#each floats as float}
      <Float float={{eventMetadata: float.event, ...float.float}} individual={true} />
      {/each}
    {:else}
    <p>This account doesn't have any FLOATs yet.</p>
    {/if}
  {/await}
</div>

<h3 class="mt-1">Events</h3>

<div class="card-container">
  {#await floatEvents}
  <Loading />
  {:then floatEvents} 
    {#if getEventsArray(floatEvents)?.length > 0}
      {#each getEventsArray(floatEvents) as floatEvent}
      <Event {floatEvent} />
      {/each}
    {:else}
    <p>This account has not created any Events yet.</p>
    {/if}
  {/await}
  
</div>