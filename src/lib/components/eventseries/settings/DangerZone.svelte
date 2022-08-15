<script>
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
      Please wait for the transaction
    </button>
  {:else if $txStatus === false}
    <button class="red outline" on:click|preventDefault={handleSubmit}>
      Revoke Event Series
    </button>
  {:else if $txStatus.success}
    <p>Revoke EventSeries successfully!</p>
    <a
      href="/{eventSeries.identifier.host}/?tab=challenges"
      role="button"
      style="width: 100%;"
    >
      View Series
    </a>
  {:else if !$txStatus.success && $txStatus.error}
    <p>{JSON.stringify($txStatus.error)}</p>
    <button on:click|preventDefault={handleReset}> Continue </button>
  {/if}
{/if}
