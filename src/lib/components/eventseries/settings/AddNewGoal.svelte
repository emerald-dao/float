<script>
  import EventItem from "$lib/components/eventseries/elements/EventItem.svelte";
  import Loading from "$lib/components/common/Loading.svelte";
  import GoalDisplay from "../elements/GoalDisplay.svelte";
  import { createEventDispatcher } from "svelte";
  import { user, eventSeries as seriesStore } from "$lib/flow/stores";
  import {
    getEventSeriesGoals,
    addAchievementGoalToEventSeries,
  } from "$lib/flow/actions";

  /** @type {import('../types').EventSeriesData} */
  export let eventSeries;

  // dispatcher
  const dispatch = createEventDispatcher();

  $: isValid = eventSeries.identifier.host === $user?.addr;
  $: eventSlots = eventSeries.slots.filter((one) => !!one.event);
  $: requiredSlots = eventSeries.slots.filter((one) => one.required);

  /** @type {import('../types').AddAchievementGoalRequest} */
  let requestParams;
  let goalsPromise;
  let selected = {};

  const txInProgress = seriesStore.AddAchievementGoal.InProgress;
  const txStatus = seriesStore.AddAchievementGoal.Status;

  // init with false
  handleReset();

  function handleReset() {
    if ($txStatus?.success) {
      dispatch("seriesUpdated");
    }
    txInProgress.set(false);
    txStatus.set(false);
    requestParams = {
      type: "byAmount",
      seriesId: eventSeries.identifier.id,
      points: 100,
      params: {
        eventsAmount: 1,
        requiredEventsAmount: 0,
      },
    };
    selected = {};

    goalsPromise = getEventSeriesGoals(
      eventSeries.identifier.host,
      eventSeries.identifier.id
    );
  }

  function onToggleSelect(eventId) {
    if (requestParams.type !== "bySpecifics") return;

    /** @type {import('../types').Identifier[]}  */
    const slots = requestParams.params?.events;
    const idx = slots.findIndex((one) => one.id === eventId);
    if (idx > -1) {
      slots.splice(idx, 1);
      selected[eventId] = false;
    } else {
      slots.push({ host: eventSeries.identifier.host, id: eventId });
      selected[eventId] = true;
    }
    requestParams.params.events = slots;
  }

  $: isValidToSubmit =
    requestParams.points > 0 &&
    !!requestParams.type &&
    ((requestParams.type === "byAmount" &&
      requestParams.params.eventsAmount > 0) ||
      (requestParams.type === "byPercent" &&
        requestParams.params.percent > 0) ||
      (requestParams.type === "bySpecifics" &&
        requestParams.params.events?.length > 0));

  async function handleAddNewGoals() {
    if (!isValidToSubmit) return;

    await addAchievementGoalToEventSeries(requestParams);
  }
</script>

{#if isValid}
  {#await goalsPromise}
    <Loading />
  {:then goals}
    {#each goals as goal, index}
      <GoalDisplay {goal} totalSlots={eventSeries.slots.length} />
    {/each}
  {/await}
  <details>
    <summary role="button" class="secondary"> <b>Add a new goal →</b> </summary>
    <div class="grid no-break mb-1">
      <button
        class:secondary={requestParams.type !== "byAmount"}
        class="outline"
        on:click={() => {
          requestParams.type = "byAmount";
          requestParams.params = {
            eventsAmount: 1,
            requiredEventsAmount: 0,
          };
        }}
      >
        By Amount
        <span>Achieve by collecting amount of FLOATs.</span>
      </button>
      <button
        class:secondary={requestParams.type !== "byPercent"}
        class="outline"
        on:click={() => {
          requestParams.type = "byPercent";
          requestParams.params = {
            percent: 100,
          };
        }}
      >
        By Percent
        <span>Achieve by collecting percentage of FLOATs in this series.</span>
      </button>
      <button
        class:secondary={requestParams.type !== "bySpecifics"}
        class="outline"
        on:click={() => {
          requestParams.type = "bySpecifics";
          requestParams.params = {
            events: [],
          };
        }}
      >
        By Specifics
        <span>Achieve by collecting some specific FLOATs.</span>
      </button>
    </div>
    <label for="points">
      <span class:highlight={requestParams.points > 0}> Goal points </span>
      <input
        type="number"
        id="points"
        name="points"
        min="1"
        max="1000"
        placeholder="ex. 100"
        step="10"
        bind:value={requestParams.points}
      />
    </label>
    {#if requestParams.type === "byAmount"}
      <div class="flex flex-gap mb-1">
        <label for="eventsAmount" class="flex-auto">
          <span class:highlight={requestParams.params.eventsAmount > 0}>
            FLOATs Amount
          </span>
          <input
            type="number"
            id="eventsAmount"
            name="eventsAmount"
            placeholder="ex. 1"
            min="1"
            max={eventSeries.slots.length}
            required
            disabled={$txInProgress}
            bind:value={requestParams.params.eventsAmount}
            on:change={(e) => {
              requestParams.params.eventsAmount = Math.min(
                requestParams.params.eventsAmount,
                eventSeries.slots.length
              );
            }}
          />
        </label>
        <!-- Range slider -->
        <label for="requiredEventsAmount">
          <span class:highlight={requestParams.params.requiredEventsAmount > 0}>
            With <i>Required</i> Amount:
            {requestParams.params.requiredEventsAmount ?? 0}
          </span>
          <input
            type="range"
            id="requiredEventsAmount"
            name="requiredEventsAmount"
            min="0"
            max={Math.min(
              requestParams.params.eventsAmount || 0,
              requiredSlots.length
            )}
            required
            disabled={$txInProgress}
            bind:value={requestParams.params.requiredEventsAmount}
          />
        </label>
      </div>
    {:else if requestParams.type === "byPercent"}
      <label for="percent">
        <span class:highlight={requestParams.params.percent > 0}>
          Percent:
          {requestParams.params.percent ?? 0} %
        </span>
        <input
          type="range"
          id="percent"
          name="percent"
          min="1"
          max="100"
          required
          disabled={$txInProgress}
          bind:value={requestParams.params.percent}
        />
      </label>
    {:else}
      <div class="flex-wrap flex-gap mb-1">
        {#each eventSlots as slot (`${slot.event.host}#${slot.event.id}`)}
          <EventItem
            item={slot}
            preview={true}
            ghost={!selected[slot.event.id]}
            pending={selected[slot.event.id]}
            disabled={$txInProgress}
            on:clickItem={(e) => onToggleSelect(slot.event.id)}
          />
        {/each}
      </div>
    {/if}
    {#if $txInProgress}
      <button aria-busy="true" disabled> Adding new Goal </button>
    {:else if $txStatus === false}
      <button
        on:click|preventDefault={handleAddNewGoals}
        disabled={!isValidToSubmit}
      >
        Submit new Goal
      </button>
    {:else}
      {#if $txStatus.success}
        <p>Goals updated successfully!</p>
      {:else if !$txStatus.success && $txStatus.error}
        <p>{JSON.stringify($txStatus.error)}</p>
      {/if}
      <button on:click|preventDefault={handleReset}> Continue </button>
    {/if}
  </details>
{/if}

<style>
  .outline {
    text-align: left;
  }

  .outline span {
    display: block;
    font-size: 0.75rem;
    line-height: 1.2;
    font-weight: 400;
    opacity: 0.6;
  }

  .highlight {
    color: var(--primary);
  }
</style>
