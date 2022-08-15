<script>
  import { t } from "svelte-i18n";
  import { createEventDispatcher } from "svelte";
  import AddNewGoal from "$lib/components/eventseries/settings/AddNewGoal.svelte";
  import AddNewStrategy from "$lib/components/eventseries/settings/AddNewStrategy.svelte";
  import ManageTreasury from "$lib/components/eventseries/settings/ManageTreasury.svelte";
  import UpdateSlots from "$lib/components/eventseries/settings/UpdateSlots.svelte";
  import DangerZone from "$lib/components/eventseries/settings/DangerZone.svelte";

  // dispatcher
  const dispatch = createEventDispatcher();

  /** @type {import('../types').EventSeriesData} */
  export let eventSeries;
</script>

<h4>{$t("challenges.detail.main.title-slots")}</h4>
<UpdateSlots
  {eventSeries}
  on:seriesUpdated={function () {
    dispatch("seriesUpdated");
  }}
/>
<h4>{$t("challenges.detail.main.title-goals")}</h4>
<AddNewGoal
  {eventSeries}
  on:seriesUpdated={function () {
    dispatch("seriesUpdated");
  }}
/>
<h4>{$t("challenges.detail.main.title-treasury")}</h4>
<ManageTreasury
  {eventSeries}
  on:seriesUpdated={function () {
    dispatch("seriesUpdated");
  }}
/>
<h4>{$t("challenges.detail.main.title-rewards")}</h4>
<AddNewStrategy
  {eventSeries}
  on:seriesUpdated={function () {
    dispatch("seriesUpdated");
  }}
/>
<h4>{$t("challenges.detail.settings.danger.title")}</h4>
<DangerZone {eventSeries} />
