<script>
  import { t } from "svelte-i18n";
  import Loading from "$lib/components/common/Loading.svelte";
  import EventItem from "$lib/components/eventseries/elements/EventItem.svelte";
  import AchievementGoals from "$lib/components/eventseries/summary/AchievementGoals.svelte";
  import { createEventDispatcher } from "svelte";
  import { user } from "$lib/flow/stores";
  import {
    getEventSeriesGoals,
    getAndCheckEventSeriesGoals,
  } from "$lib/flow/actions";

  /** @type {import('../types').EventSeriesData} */
  export let eventSeries;
  // dispatcher
  const dispatch = createEventDispatcher();

  /** @type {Promise<import('../types').EventSeriesUserStatus>} */
  let statusPromise = Promise.resolve();

  $: preview = !$user?.addr;
  $: {
    const addr = $user?.addr;
    if (addr) {
      statusPromise = getAndCheckEventSeriesGoals(
        addr,
        eventSeries.identifier.host,
        eventSeries.identifier.id
      );
    } else {
      statusPromise = getEventSeriesGoals(
        eventSeries.identifier.host,
        eventSeries.identifier.id
      ).then((goals) => {
        return { goals, owned: [] };
      });
    }
  }

  /**
   * @param {import('../types').Identifier[]} owned
   * @param {import('../types').EventSeriesSlot} slot
   */
  function isOwned(owned, slot) {
    if (!slot.event) return false;
    const mapped = owned.map((one) => `${one.host}#${one.id}`);
    return mapped.indexOf(`${slot.event.host}#${slot.event.id}`) > -1;
  }
</script>

{#await statusPromise}
  <Loading />
{:then userStatus}
  <h4>{$t("challenges.detail.main.title-slots")}</h4>
  <div class="flex-wrap flex-gap mb-1">
    {#each eventSeries.slots as slot, index ("slot#" + index)}
      <EventItem
        item={slot}
        {preview}
        owned={preview ? false : isOwned(userStatus?.owned, slot)}
      />
    {/each}
  </div>
  <AchievementGoals
    {eventSeries}
    {userStatus}
    on:seriesUpdated={(e) => dispatch("seriesUpdated")}
  />
{/await}
