<script>
  import { t } from "svelte-i18n";
  import { user, eventSeries as seriesStore } from "$lib/flow/stores";
  import { revokeEventSeries } from "$lib/flow/actions";

  /** @type {import('../types').EventSeriesData} */
  export let eventSeries;

  // dispatcher
  $: isValid = eventSeries.identifier.host === $user?.addr;

  const txInProgress = seriesStore.Revoke.InProgress;
  const txStatus = seriesStore.Revoke.Status;

  // init with false
  handleReset();

  function handleReset() {
    txInProgress.set(false);
    txStatus.set(false);
  }

  function handleSubmit() {
    revokeEventSeries(eventSeries.identifier.id);
  }
</script>

{#if isValid}
  {#if $txInProgress}
    <button class="red outline" aria-busy="true" disabled>
      {$t("common.hint.please-wait-for-tx")}
    </button>
  {:else if $txStatus === false}
    <button class="red outline" on:click|preventDefault={handleSubmit}>
      {$t("challenges.detail.settings.danger.btn-submit")}
    </button>
  {:else if $txStatus.success}
    <p>{$t("common.hint.tx-successful")}</p>
    <a
      href="/{eventSeries.identifier.host}/?tab=challenges"
      role="button"
      style="width: 100%;"
    >
      {$t("challenges.detail.settings.danger.on-success-next")}
    </a>
  {:else if !$txStatus.success && $txStatus.error}
    <p>{JSON.stringify($txStatus.error)}</p>
    <button on:click|preventDefault={handleReset}>
      {$t("common.btn.continue")}
    </button>
  {/if}
{/if}
