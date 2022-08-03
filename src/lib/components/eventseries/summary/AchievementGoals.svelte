<script>
  import GoalDisplay from "../elements/GoalDisplay.svelte";
  import { createEventDispatcher } from "svelte";
  import { user, eventSeries as seriesStore } from "$lib/flow/stores";
  import { accompllishGoals } from "$lib/flow/actions";

  /** @type {import('../types').EventSeriesData} */
  export let eventSeries;
  /** @type {import('../types').EventSeriesUserStatus} */
  export let userStatus;

  // dispatcher
  const dispatch = createEventDispatcher();

  const txInProgress = seriesStore.AccompllishGoals.InProgress;
  const txStatus = seriesStore.AccompllishGoals.Status;

  $: isValidToSubmit = !!userStatus.goals.find((one) => one.status === "1");

  async function handleRequest() {
    if (!isValidToSubmit) return;

    const goalIdx = [];
    for (let i = 0; i < userStatus.goals.length; i++) {
      if (userStatus.goals[i].status === "1") {
        goalIdx.push(i);
      }
    }
    await accompllishGoals(
      eventSeries.identifier.host,
      eventSeries.identifier.id,
      goalIdx
    );

    if ($txStatus?.success) {
      dispatch("seriesUpdated");
    }
  }
</script>

<h4>Series Goals</h4>
{#each userStatus.goals as goal}
  <GoalDisplay
    {goal}
    preview={false}
    totalSlots={eventSeries.slots.length}
    owned={userStatus.owned}
  />
{/each}
