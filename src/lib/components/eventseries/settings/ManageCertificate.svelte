<script>
  import { t } from "svelte-i18n";
  import { createEventDispatcher } from "svelte";
  import { user, eventSeries as seriesStore } from "$lib/flow/stores";
  import ExternalLink from "../svgs/ExternalLink.svelte";
  import CopyBadge from "$lib/components/common/CopyBadge.svelte";

  /** @type {import('../types').EventSeriesData} */
  export let eventSeries;

  // dispatcher
  const dispatch = createEventDispatcher();

  $: isValid = eventSeries.identifier.host === $user?.addr;

  const txInProgress = seriesStore.SyncCertificates.InProgress;
  const txStatus = seriesStore.SyncCertificates.Status;

  /** @type {'generate' | 'sync'} */
  let mode;
  let generatePoints = 0;
  let generatedCodes = undefined;

  function handleGenerate() {
    if (generatePoints > 0) {
      generatedCodes = `${eventSeries.identifier.host}:${eventSeries.identifier.id}:${generatePoints}`;
    }
  }

  // init with false
  handleReset();

  function handleReset() {
    if ($txStatus?.success) {
      dispatch("seriesUpdated");
    }

    mode = "generate";
    generatePoints = 0;
  }

  $: isValidToSubmit = false;

  async function handleSubmit() {
    if (!isValidToSubmit) return;

    // TODO
  }
</script>

{#if isValid}
  <details>
    <summary role="button" class="secondary">
      <b>{$t("challenges.detail.settings.cert.title")}</b>
    </summary>
    <div class="grid no-break mb-1">
      <button
        class:secondary={mode !== "generate"}
        class="outline"
        disabled={$txInProgress}
        on:click={function () {
          mode = "generate";
          generatePoints = 0;
          generatedCodes = "";
        }}
      >
        {$t("challenges.detail.settings.cert.select-generate")}
        <span>
          {$t("challenges.detail.settings.cert.select-generate-desc")}
        </span>
      </button>
      <button
        class:secondary={mode !== "sync"}
        class="outline"
        disabled={$txInProgress}
        on:click={function () {
          mode = "sync";
        }}
      >
        {$t("challenges.detail.settings.cert.select-sync")}
        <span>
          {$t("challenges.detail.settings.cert.select-sync-desc")}
        </span>
      </button>
    </div>
    {#if mode === "generate"}
      <div class="flex flex-gap mb-1">
        <label for="generatePoints" class="flex-auto">
          <span class:highlight={generatePoints > 0}>
            {$t("challenges.detail.summary.achievement-point")}
          </span>
          <input
            type="number"
            id="generatePoints"
            name="generatePoints"
            placeholder={$t("common.hint.placeholder-ex", {
              values: { ex: 100 },
            })}
            min="1"
            step="100"
            required
            disabled={$txInProgress}
            bind:value={generatePoints}
          />
        </label>
        <button
          on:click|preventDefault={handleGenerate}
          disabled={generatePoints === 0}
        >
          {$t("challenges.detail.settings.cert.select-generate")}
        </button>
      </div>
      {#if generatedCodes}
        <div class="flex flex-col flex-gap">
          <span>
            <code data-tooltip="Certificate Code" class="flex-none">
              {generatedCodes}
            </code>
            <CopyBadge text={generatedCodes} />
          </span>
          <a href="/create" target="_blank">
            {$t("events.common.create")}
            <ExternalLink />
          </a>
        </div>
      {/if}
    {:else}
      <div class="flex-wrap flex-gap mb-1">
        <!-- TODO -->
      </div>
      {#if $txInProgress}
        <button aria-busy="true" disabled>
          {$t("common.hint.please-wait-for-tx")}
        </button>
      {:else if $txStatus === false}
        <button
          on:click|preventDefault={handleSubmit}
          disabled={!isValidToSubmit}
        >
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
    {/if}
  </details>
{/if}

<style>
  .outline {
    text-align: left;
  }

  .outline span {
    display: block;
    font-size: 0.75rem;
    line-height: 1.2;
    font-weight: 400;
    opacity: 0.6;
  }
</style>
