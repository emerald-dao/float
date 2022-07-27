<script>
  import AddNewGoal from "$lib/components/eventseries/settings/AddNewGoal.svelte";
  import AddNewStrategy from "$lib/components/eventseries/settings/AddNewStrategy.svelte";
  import ManageTreasury from "$lib/components/eventseries/settings/ManageTreasury.svelte";
  import UpdateSlots from "$lib/components/eventseries/settings/UpdateSlots.svelte";

  /** @type {import('../types').EventSeriesData} */
  export let eventSeries;
</script>

<h4>FLOAT Events in the series</h4>
<UpdateSlots {eventSeries} />
<h4>Series Goals</h4>
<AddNewGoal {eventSeries} />
<h4>Series Treasury</h4>
<ManageTreasury {eventSeries} />
<h4>Reward Strategies</h4>
<AddNewStrategy {eventSeries} />
