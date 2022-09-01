<script>
  import { t } from "svelte-i18n";
  import EventItem from "$lib/components/eventseries/elements/EventItem.svelte";
  import Loading from "$lib/components/common/Loading.svelte";
  import GoalDisplay from "../elements/GoalDisplay.svelte";
  import PrimaryTag from "../elements/PrimaryTag.svelte";
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

  function onToggleSelect(host, eventId) {
    if (requestParams.type !== "bySpecifics") return;

    /** @type {import('../types').Identifier[]}  */
    const slots = requestParams.params?.events;
    const idx = slots.findIndex((one) => one.id === eventId);
    if (idx > -1) {
      slots.splice(idx, 1);
      selected[eventId] = false;
    } else {
      slots.push({ host, id: eventId });
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
    <div class="mb-1">
      {#each goals as goal, index}
        <GoalDisplay {goal} totalSlots={eventSeries.slots.length} />
      {/each}
    </div>
  {/await}
  <details>
    <summary role="button" class="secondary">
      <b>{$t("challenges.detail.settings.goal.title")}</b>
    </summary>
    <div class="grid no-break mb-1">
      <button
        class:secondary={requestParams.type !== "byAmount"}
        class="outline"
        disabled={$txInProgress}
        on:click={function () {
          requestParams.type = "byAmount";
          requestParams.params = {
            eventsAmount: 1,
            requiredEventsAmount: 0,
          };
        }}
      >
        {$t("challenges.detail.settings.goal.select-by-amount")}
        <span
          >{$t("challenges.detail.settings.goal.select-by-amount-desc")}</span
        >
      </button>
      <button
        class:secondary={requestParams.type !== "byPercent"}
        class="outline"
        disabled={$txInProgress}
        on:click={function () {
          requestParams.type = "byPercent";
          requestParams.params = {
            percent: 100,
          };
        }}
      >
        {$t("challenges.detail.settings.goal.select-by-percent")}
        <span>
          {$t("challenges.detail.settings.goal.select-by-percent-desc")}
        </span>
      </button>
      <button
        class:secondary={requestParams.type !== "bySpecifics"}
        class="outline"
        disabled={$txInProgress}
        on:click={function () {
          requestParams.type = "bySpecifics";
          requestParams.params = {
            events: [],
          };
        }}
      >
        {$t("challenges.detail.settings.goal.select-by-specifics")}
        <span>
          {$t("challenges.detail.settings.goal.select-by-specifics-desc")}
        </span>
      </button>
    </div>
    <label for="points">
      <span class:highlight={requestParams.points > 0}>
        {$t("challenges.detail.settings.goal.points")}
      </span>
      <input
        type="number"
        id="points"
        name="points"
        min="1"
        max="1000"
        placeholder={$t("common.hint.placeholder-ex", {
          values: { ex: 100 },
        })}
        step="10"
        disabled={$txInProgress}
        bind:value={requestParams.points}
      />
    </label>
    {#if requestParams.type === "byAmount"}
      <div class="flex flex-gap">
        <label for="eventsAmount" class="flex-auto">
          <span class:highlight={requestParams.params.eventsAmount > 0}>
            {$t("challenges.detail.settings.goal.floats-amount")}
          </span>
          <input
            type="number"
            id="eventsAmount"
            name="eventsAmount"
            placeholder={$t("common.hint.placeholder-ex", {
              values: { ex: 1 },
            })}
            min="1"
            max={eventSeries.slots.length}
            required
            disabled={$txInProgress}
            bind:value={requestParams.params.eventsAmount}
            on:change={function () {
              requestParams.params.eventsAmount = Math.min(
                requestParams.params.eventsAmount,
                eventSeries.slots.length
              );
            }}
          />
        </label>
        <!-- Range slider -->
        <label for="requiredEventsAmount">
          <small
            class="flex-wrap center flex-gap narrow"
            class:highlight={requestParams.params.requiredEventsAmount > 0}
          >
            {$t("challenges.detail.settings.goal.with-required-amount", {
              values: { n: requestParams.params.requiredEventsAmount ?? 0 },
            })}
            <PrimaryTag />
          </small>
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
          {$t("challenges.detail.settings.goal.floats-percent", {
            values: { percent: requestParams.params.percent ?? 0 },
          })}
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
      <div class="flex-wrap flex-gap">
        {#each eventSlots as slot (`${slot.event.host}#${slot.event.id}`)}
          <EventItem
            item={slot}
            preview={true}
            ghost={!selected[slot.event.id]}
            pending={selected[slot.event.id]}
            disabled={$txInProgress}
            on:clickItem={function () {
              onToggleSelect(slot.event.host, slot.event.id);
            }}
          />
        {/each}
      </div>
    {/if}

    <label for="goal-title mb-1">
      <span class:highlight={!!requestParams.title}>
        {$t("challenges.detail.settings.goal.set-title")}
      </span>
      <input
        type="text"
        id="goal-title"
        name="goal-title"
        maxlength="30"
        bind:value={requestParams.title}
      />
    </label>

    {#if $txInProgress}
      <button aria-busy="true" disabled>
        {$t("common.hint.please-wait-for-tx")}
      </button>
    {:else if $txStatus === false}
      <button
        on:click|preventDefault={handleAddNewGoals}
        disabled={!isValidToSubmit}
      >
        {$t("challenges.detail.settings.goal.btn-submit")}
      </button>
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
</style>
