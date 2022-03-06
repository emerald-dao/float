<script>
import { page } from '$app/stores';

  import Loading from '$lib/components/common/Loading.svelte';
  import Event from '$lib/components/Event.svelte';
  import { getEvents } from '$lib/flow/actions.js'
  
  let floatEvents = getEvents($page.params.address);
  
  function getEventsArray(floatEventsObj) {
    if(floatEventsObj && Object.keys(floatEventsObj)?.length > 0) {
      return Object.values(floatEventsObj);
    } else {
      return []
    }
  }
</script>

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