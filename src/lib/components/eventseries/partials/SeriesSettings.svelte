<script>
  import AddNewGoal from "$lib/components/eventseries/settings/AddNewGoal.svelte";
  import AddNewStrategy from "$lib/components/eventseries/settings/AddNewStrategy.svelte";
  import ManageTreasury from "$lib/components/eventseries/settings/ManageTreasury.svelte";
  import EventItem from "$lib/components/eventseries/elements/EventItem.svelte";
  import DialogPickingEvents from "$lib/components/eventseries/DialogPickingEvents.svelte";
  import { prevent_default } from "svelte/internal";

  /** @type {import('../types').EventSeriesData} */
  export let eventSeries;

  $: emptySlotAmount = eventSeries.slots.filter((slot) => !slot.event).length;

  let dialogOpened = false;
  /** @type {import('../types').EventSeriesSlot[]} */
  let pendingSlots = [];

  /**
   * events added
   *
   * @param {object} added
   * @param {string} added.host
   * @param {string[]} added.picked
   */
  function onEventsAdded(added) {
    const currentExists = eventSeries.slots.reduce((prev, curr) => {
      if (!curr.event) return prev;
      prev.add(`${curr.event.host}#${curr.event.id}`);
      return prev;
    }, new Set());
    const events = added.picked
      .map((one) => ({
        host: added.host,
        id: one,
      }))
      .filter((one) => !currentExists.has(`${one.host}#${one.id}`));
    pendingSlots = events.map((event) => ({
      event,
      required: false,
    }));
  }

  $: mergedSlots = pendingSlots.reduce((prev, curr) => {
    const firstEmptyIdx = prev.findIndex((one) => !one.event);
    if (firstEmptyIdx >= 0) {
      prev[firstEmptyIdx] = {
        event: curr.event,
        required: prev[firstEmptyIdx].required,
        pending: true,
      };
    }
    return prev;
  }, eventSeries.slots.slice());
</script>

<h4>FLOAT Events in the series</h4>
<div class="flex-wrap flex-gap mb-1">
  {#each mergedSlots as slot, index (slot.event ? `${slot.event.host}#${slot.event.id}` : "emptySlot#" + index)}
    <EventItem item={slot} preview={true} pending={!!slot.pending} />
  {/each}
</div>
{#if emptySlotAmount > 0 && pendingSlots.length === 0}
  <button on:click={(e) => (dialogOpened = true)}>Fill Event Slots</button>
{/if}
<h4>Series Goals</h4>
<AddNewGoal />
<h4>Series Treasury</h4>
<ManageTreasury />
<h4>Reward Strategies</h4>
<AddNewStrategy />

<DialogPickingEvents
  bind:opened={dialogOpened}
  on:add={(e) => onEventsAdded(e.detail)}
/>
