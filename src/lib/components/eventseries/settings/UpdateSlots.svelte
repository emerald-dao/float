<script>
  import { t } from "svelte-i18n";
  import { createEventDispatcher } from "svelte";
  import EventItem from "$lib/components/eventseries/elements/EventItem.svelte";
  import DialogPickingEvents from "$lib/components/eventseries/DialogPickingEvents.svelte";
  import { user, eventSeries as seriesStore } from "$lib/flow/stores";
  import { updateEventseriesSlots } from "$lib/flow/actions";

  // dispatcher
  const dispatch = createEventDispatcher();

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

  $: isValidToSumbit =
    pendingSlots.length > 0 && $user?.addr === eventSeries.identifier?.host;

  const txInProgress = seriesStore.UpdateSlots.InProgress;
  const txStatus = seriesStore.UpdateSlots.Status;
  // init with false
  handleReset();

  function handleUpdateSlots() {
    if (!isValidToSumbit) return;

    updateEventseriesSlots(
      eventSeries.identifier.id,
      mergedSlots
        .map((slot, index) => {
          if (!slot.pending) return null;
          return {
            index: String(index),
            eventId: String(slot.event.id),
            host: slot.event.host,
          };
        })
        .filter((one) => !!one)
    );
  }

  function handleReset() {
    if ($txStatus?.success) {
      dispatch("seriesUpdated");
    }
    txInProgress.set(false);
    txStatus.set(false);
    pendingSlots = [];
  }
</script>

<div class="flex-wrap flex-gap mb-1">
  {#each mergedSlots as slot, index (slot.event ? `${slot.event.host}#${slot.event.id}@${index}` : "emptySlot#" + index)}
    <EventItem item={slot} preview={true} pending={!!slot.pending} />
  {/each}
</div>
{#if emptySlotAmount > 0}
  {#if $txInProgress}
    <button aria-busy="true" disabled>
      {$t("common.hint.please-wait-for-tx")}
    </button>
  {:else if $txStatus === false}
    {#if pendingSlots.length === 0}
      <button on:click={(e) => (dialogOpened = true)}>
        {$t("challenges.detail.settings.slots.btn-fill-events")}
      </button>
    {:else}
      <button
        on:click|preventDefault={handleUpdateSlots}
        disabled={!isValidToSumbit}
      >
        {$t("challenges.detail.settings.slots.btn-submit")}
      </button>
    {/if}
  {:else}
    {#if $txStatus.success}
      <p>{$t("common.hint.tx-successful")}</p>
    {:else if !$txStatus.success && $txStatus.error}
      <p>{JSON.stringify($txStatus.error)}</p>
    {/if}
    <button on:click|preventDefault={handleReset}>
      {$t("common.btn.continue")}
    </button>
  {/if}
{/if}

<DialogPickingEvents
  bind:opened={dialogOpened}
  on:add={function (e) {
    onEventsAdded(e.detail);
  }}
/>
