<script>
  import { t } from "svelte-i18n";
  import EventCertificateItem from "./EventCertificateItem.svelte";
  import { createEventDispatcher } from "svelte";
  import { user, eventSeries as seriesStore } from "$lib/flow/stores";
  import { syncCertificateFloats } from "$lib/flow/actions";

  /** @type {import('../types').EventSeriesData} */
  export let eventSeries;

  export let events;

  // dispatcher
  const dispatch = createEventDispatcher();

  const txInProgress = seriesStore.SyncCertificates.InProgress;
  const txStatus = seriesStore.SyncCertificates.Status;

  $: isValid = eventSeries.identifier.host === $user?.addr;

  // init with false
  handleReset();

  function handleReset() {
    if ($txStatus?.success) {
      dispatch("seriesUpdated");
    }
    txInProgress.set(false);
    txStatus.set(false);
  }

  $: isValidToSubmit = isValid;

  async function handleSubmit() {
    if (!isValidToSubmit) return;

    syncCertificateFloats({
      seriesId: eventSeries.identifier.id,
      events: events.map((one) => one.event),
    });
  }
</script>

<div class="flex-wrap flex-gap mb-1">
  {#each events as one, index (one.event ? `${one.event.host}#${one.event.eventId}@${index}` : "emptySlot#" + index)}
    <EventCertificateItem event={one.event} points={one.points} owned={false} />
  {/each}
</div>

{#if $txInProgress}
  <button aria-busy="true" disabled>
    {$t("common.hint.please-wait-for-tx")}
  </button>
{:else if $txStatus === false}
  <button on:click|preventDefault={handleSubmit} disabled={!isValidToSubmit}>
    {$t("challenges.detail.settings.cert.btn-submit-sync")}
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
