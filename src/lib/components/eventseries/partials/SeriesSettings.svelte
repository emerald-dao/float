<script>
  import { t } from "svelte-i18n";
  import { createEventDispatcher } from "svelte";
  import AddNewGoal from "$lib/components/eventseries/settings/AddNewGoal.svelte";
  import AddNewStrategy from "$lib/components/eventseries/settings/AddNewStrategy.svelte";
  import ManageTreasury from "$lib/components/eventseries/settings/ManageTreasury.svelte";
  import UpdateSlots from "$lib/components/eventseries/settings/UpdateSlots.svelte";
  import DangerZone from "$lib/components/eventseries/settings/DangerZone.svelte";
  import ManageCertificate from "../settings/ManageCertificate.svelte";

  // dispatcher
  const dispatch = createEventDispatcher();

  /** @type {import('../types').EventSeriesData} */
  export let eventSeries;
</script>

<h4 class="subtitle">{$t("challenges.detail.main.title-slots")}</h4>
<p class="subtitle-desc">
  {$t("challenges.detail.main.title-desc-settings-slots")}
</p>
<UpdateSlots
  {eventSeries}
  on:seriesUpdated={function () {
    dispatch("seriesUpdated");
  }}
/>
<h4 class="subtitle">{$t("challenges.detail.main.title-goals")}</h4>
<p class="subtitle-desc">
  {$t("challenges.detail.main.title-desc-settings-goals")}
</p>
<AddNewGoal
  {eventSeries}
  on:seriesUpdated={function () {
    dispatch("seriesUpdated");
  }}
/>
<h4 class="subtitle">{$t("challenges.detail.main.title-certificate")}</h4>
<p class="subtitle-desc">
  {$t("challenges.detail.main.title-desc-setting-certificate")}
</p>
<ManageCertificate
  {eventSeries}
  on:seriesUpdated={function () {
    dispatch("seriesUpdated");
  }}
/>
<h4 class="subtitle">{$t("challenges.detail.main.title-treasury")}</h4>
<p class="subtitle-desc">
  {$t("challenges.detail.main.title-desc-settings-treasury")}
</p>
<ManageTreasury
  {eventSeries}
  on:seriesUpdated={function () {
    dispatch("seriesUpdated");
  }}
/>
<h4 class="subtitle">{$t("challenges.detail.main.title-rewards")}</h4>
<p class="subtitle-desc">
  {$t("challenges.detail.main.title-desc-settings-strategies")}
</p>
<AddNewStrategy
  {eventSeries}
  on:seriesUpdated={function () {
    dispatch("seriesUpdated");
  }}
/>
<h4 class="subtitle">{$t("challenges.detail.settings.danger.title")}</h4>
<p class="subtitle-desc">
  {$t("challenges.detail.main.title-desc-settings-danger")}
</p>
<DangerZone {eventSeries} />
