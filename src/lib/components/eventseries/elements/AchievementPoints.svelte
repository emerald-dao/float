<script>
  import { t } from "svelte-i18n";
  import EnergyPoint from "$lib/components/eventseries/svgs/EnergyPoint.svelte";

  export let totalScore;
  export let consumableScore;
</script>

<h4 class="flex-wrap between">
  <span>
    {$t("challenges.detail.summary.achievement-point")}
    <span
      class="emphasis"
      data-tooltip="You can claim POINTs by achieving series goals."
    >
      {totalScore}
    </span>
  </span>
  <span>
    <EnergyPoint />
    <span
      class="emphasis"
      data-tooltip="Consumable POINTs will be consumed when claim a reward."
    >
      {consumableScore}
    </span>
  </span>
</h4>
