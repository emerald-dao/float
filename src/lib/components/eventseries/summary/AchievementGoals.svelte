<script>
  import GoalDisplay from "../elements/GoalDisplay.svelte";
  import AchievementPoints from "../elements/AchievementPoints.svelte";
  import { createEventDispatcher } from "svelte";
  import { user, eventSeries as seriesStore } from "$lib/flow/stores";
  import { accomplishGoals } from "$lib/flow/actions";

  /** @type {import('../types').EventSeriesData} */
  export let eventSeries;
  /** @type {import('../types').EventSeriesUserStatus} */
  export let userStatus = undefined;

  $: preview = !$user?.addr;

  // dispatcher
  const dispatch = createEventDispatcher();

  const txInProgress = seriesStore.AccompllishGoals.InProgress;
  const txStatus = seriesStore.AccompllishGoals.Status;

  $: isValidToSubmit =
    !preview && !!userStatus?.goals.find((one) => one.status === "1");
  $: isAllGoalsDone =
    !preview &&
    userStatus?.goals.filter((one) => one.status !== "2").length === 0;

  let ownedRequiredEventsAmount = 0;
  $: {
    if (eventSeries && userStatus && userStatus?.owned?.length > 0) {
      let totalRequiredIds = eventSeries.slots
        .filter((one) => one.required && one.event)
        .map((one) => one.event?.id);
      let count = 0;
      for (const one of userStatus?.owned) {
        if (totalRequiredIds.indexOf(one.id) > -1) {
          count++;
        }
      }
      ownedRequiredEventsAmount = count;
    }
  }

  function handleRequest() {
    if (!isValidToSubmit) return;

    const goalIdx = [];
    for (let i = 0; i < userStatus?.goals.length; i++) {
      if (userStatus.goals[i].status === "1") {
        goalIdx.push(i);
      }
    }
    accomplishGoals(
      eventSeries.identifier.host,
      eventSeries.identifier.id,
      goalIdx
    );
  }

  function handleReset() {
    if ($txStatus?.success) {
      dispatch("seriesUpdated");
    }
    txInProgress.set(false);
    txStatus.set(false);
  }
</script>

<AchievementPoints
  totalScore={preview ? 0 : userStatus?.totalScore}
  consumableScore={preview ? 0 : userStatus?.consumableScore}
/>
{#if !preview && !isAllGoalsDone}
  {#if $txInProgress}
    <button aria-busy="true" disabled> Accomplishing Goals </button>
  {:else if $txStatus === false}
    {#if !isValidToSubmit}
      <button disabled> Please collect more FLOATs in the series </button>
    {:else}
      <button
        on:click|preventDefault={handleRequest}
        disabled={!isValidToSubmit}
      >
        Accomplish Goals
      </button>
    {/if}
  {:else}
    {#if $txStatus.success}
      <p>Goals accomplished successfully!</p>
    {:else if !$txStatus.success && $txStatus.error}
      <p>{JSON.stringify($txStatus.error)}</p>
    {/if}
    <button on:click|preventDefault={handleReset}> Continue </button>
  {/if}
  <br />
{/if}
{#each userStatus.goals as goal}
  <GoalDisplay
    {goal}
    {preview}
    totalSlots={eventSeries.slots.length}
    owned={preview ? [] : userStatus?.owned}
    ownedRequiredAmount={ownedRequiredEventsAmount}
  />
{/each}
