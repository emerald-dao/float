<script>
  import { t } from "svelte-i18n";
  import Badge from "../svgs/badge.svelte";
  import EventItem from "./EventItem.svelte";

  /** @type {import('../types').EventSeriesAchievementGoal} */
  export let goal;
  /** default is preview */
  export let preview = true;
  /** @type {number} */
  export let totalSlots = 0;
  /** @type {import('../types').Identifier[]} */
  export let owned = [];
  export let ownedRequiredAmount = 0;

  $: isByAmount = goal.type === "byAmount";
  $: isByPercent = goal.type === "byPercent";

  $: isGoalReady = !preview && goal.status === "1";
  $: isGoalDone = !preview && goal.status === "2";

  $: specificEventIds = goal.params?.events?.map((one) => one.id) ?? [];
  $: progress = Math.min(
    100,
    Math.floor(
      100 *
        (isByAmount
          ? !goal.params?.eventsAmount
            ? 0
            : !goal.params?.requiredEventsAmount
            ? owned.length / goal.params?.eventsAmount
            : (ownedRequiredAmount +
                Math.min(
                  goal.params?.eventsAmount - goal.params?.requiredEventsAmount,
                  owned.length - ownedRequiredAmount
                )) /
              goal.params?.eventsAmount
          : isByPercent
          ? ((owned.length / totalSlots) * 100) / (goal.params?.percent ?? 100)
          : owned.filter((one) => specificEventIds.indexOf(one.id) > -1)
              .length / (goal.params?.events?.length ?? 1))
    )
  );

  const isOwned = (eventId) =>
    owned.filter((item) => item.id === eventId).length > 0;
</script>

<article class="panel" class:ready={isGoalReady} class:done={isGoalDone}>
  <div class="panel-start">
    {#if isGoalReady || isGoalDone}
      <Badge owned={true} huge={true} />
    {:else if isByAmount}
      <svg
        t="1659515190866"
        class="icon"
        viewBox="0 0 1024 1024"
        version="1.1"
        xmlns="http://www.w3.org/2000/svg"
        p-id="3066"
      >
        <path
          d="M960 1024H64a64 64 0 0 1-64-64V64a64 64 0 0 1 64-64h896a64 64 0 0 1 64 64v896a64 64 0 0 1-64 64z m0-896a64 64 0 0 0-64-64H128a64 64 0 0 0-64 64v768a64 64 0 0 0 64 64h768a64 64 0 0 0 64-64V128z m-128 640h-128a64 64 0 0 1 0-128h64V576h-64a64 64 0 0 1 0-128h64V384h-64a64 64 0 0 1 0-128h128a64 64 0 0 1 64 64v384a64 64 0 0 1-64 64z m-320-128a64 64 0 0 1 0 128H384a64 64 0 0 1-64-64V512a64 64 0 0 1 64-64h64V384H384a64 64 0 0 1 0-128h128a64 64 0 0 1 64 64v192a64 64 0 0 1-64 64H448v64h64z m-320 128a64 64 0 0 1-64-64V320a64 64 0 0 1 128 0v384a64 64 0 0 1-64 64z"
          p-id="3067"
        />
      </svg>
    {:else if isByPercent}
      <svg
        t="1659515263309"
        class="icon"
        viewBox="0 0 1024 1024"
        version="1.1"
        xmlns="http://www.w3.org/2000/svg"
        p-id="3978"
      >
        <path
          d="M804.571429 731.428571q0-29.714286-21.714286-51.428571t-51.428571-21.714286-51.428571 21.714286-21.714286 51.428571 21.714286 51.428571 51.428571 21.714286 51.428571-21.714286 21.714286-51.428571zm-438.857143-438.857143q0-29.714286-21.714286-51.428571t-51.428571-21.714286-51.428571 21.714286-21.714286 51.428571 21.714286 51.428571 51.428571 21.714286 51.428571-21.714286 21.714286-51.428571zm585.142857 438.857143q0 90.857143-64.285714 155.142857t-155.142857 64.285714-155.142857-64.285714-64.285714-155.142857 64.285714-155.142857 155.142857-64.285714 155.142857 64.285714 64.285714 155.142857zm-54.857143-621.714286q0 11.428571-7.428571 21.714286l-603.428571 804.571429q-10.857143 14.857143-29.142857 14.857143l-91.428571 0q-14.857143 0-25.714286-10.857143t-10.857143-25.714286q0-11.428571 7.428571-21.714286l603.428571-804.571429q10.857143-14.857143 29.142857-14.857143l91.428571 0q14.857143 0 25.714286 10.857143t10.857143 25.714286zm-384 182.857143q0 90.857143-64.285714 155.142857t-155.142857 64.285714-155.142857-64.285714-64.285714-155.142857 64.285714-155.142857 155.142857-64.285714 155.142857 64.285714 64.285714 155.142857z"
          p-id="3979"
        />
      </svg>
    {:else}
      <svg
        t="1659515299758"
        class="icon"
        viewBox="0 0 1024 1024"
        version="1.1"
        xmlns="http://www.w3.org/2000/svg"
        p-id="4521"
      >
        <path
          d="M480.768 151.04h59.008c3.456 0 10.432-3.456 10.432-10.368V43.456c0-3.456-3.52-10.368-10.432-10.368h-59.008c-3.456 0-6.976 3.456-10.432 6.912v100.672c3.456 6.912 6.976 10.368 10.432 10.368zM196.16 286.4h6.976l41.6-41.6c3.52-3.52 3.52-3.52 3.52-6.976s0-3.456-3.52-6.912L175.36 161.472c0-3.456-3.456-3.456-6.976-3.456 0 0-3.456 0-3.456 3.456l-45.12 41.6v7.04c0 3.392 0 3.392 3.456 6.912l69.44 69.376h3.456z m704.576-83.264l-41.664-41.664c0-3.456-3.456-3.456-6.976-3.456-3.456 0-3.456 0-6.912 3.456l-69.44 69.44c-3.456 3.456-3.456 3.456-3.456 6.912s0 3.456 3.456 6.976l41.664 41.6h6.976c3.456 0 3.456 0 6.912-3.456l69.44-69.44c3.456-3.456 3.456-3.456 3.456-6.912l-3.456-3.456zM147.584 890.24h728.832v69.44H147.584V890.24z m34.688-100.608c0 17.28 13.888 31.232 31.232 31.232h121.472V557.12h65.92v263.808h409.6a31.104 31.104 0 0 0 31.232-31.232V546.752A329.6 329.6 0 0 0 512 216.96c-180.48 0-329.728 149.248-329.728 329.728v242.944z"
          p-id="4522"
        />
      </svg>
    {/if}
  </div>
  <div class="panel-content">
    {#if isByAmount}
      <div>
        {$t("challenges.elements.goal.label-collect")}
        <span class="emphasis">
          {goal.params.eventsAmount}
        </span>
        {$t("common.main.floats")}
        {#if goal.params.requiredEventsAmount > 0}
          {$t("challenges.elements.goal.by-amount-with")}
          <span class="emphasis">
            {goal.params.requiredEventsAmount}
          </span>
          <Badge required />
        {/if}
      </div>
    {:else if isByPercent}
      <div>
        {$t("challenges.elements.goal.label-collect")}
        <span class="emphasis">{goal.params.percent}% </span>
        {$t("challenges.detail.main.title-slots")}
      </div>
    {:else}
      <div class="flex-wrap flex-gap">
        {#each goal.params.events as one (`${one.host}#${one.id}`)}
          <EventItem
            item={{ event: one, required: true }}
            {preview}
            pending={preview}
            ghost={preview}
            owned={!preview && isOwned(one.id)}
          />
        {/each}
      </div>
    {/if}
    <b class:emphasis={isGoalReady}>
      {$t("challenges.elements.goal.label-points", {
        values: {
          points: "goal.points",
        },
      })}
    </b>
  </div>
  {#if !preview}
    <div class="panel-bg" style="width: {progress}%;" />
  {/if}
</article>

<style>
  .panel-content {
    flex: 1 1 auto;
    padding: 0.2rem 1rem 0.2rem 0;
    display: flex;
    flex-wrap: wrap;
    justify-content: space-between;
    align-items: center;
  }
</style>
