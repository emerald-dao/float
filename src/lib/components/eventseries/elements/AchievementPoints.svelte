<script>
  import EnergyPoint from "$lib/components/eventseries/svgs/EnergyPoint.svelte";

  export let totalScore;
  export let consumableScore;
</script>

<h4 class="flex-wrap between">
  <span>
    Achievement Points: &nbsp;
    <span
      class="emphasis"
      data-tooltip="You can claim POINTs by achieving following goals."
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
