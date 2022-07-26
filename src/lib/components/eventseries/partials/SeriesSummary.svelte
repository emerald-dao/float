<script>
  import EventItem from "$lib/components/eventseries/elements/EventItem.svelte";

  /** @type {import('../types').EventSeriesData} */
  export let eventSeries;
</script>

<h4 class="">FLOAT Events in the series</h4>
<div class="flex-wrap flex-gap mb-1">
  {#each eventSeries.slots as slot, index ("slot#" + index)}
    <EventItem item={slot} />
  {/each}
</div>
