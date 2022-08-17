<script>
  import { t } from "svelte-i18n";
  import CopyBadge from "$lib/components/common/CopyBadge.svelte";
  import ExternalLink from "../svgs/ExternalLink.svelte";
  import EventsQuery from "../EventsQuery.svelte";
  import EventCertificateItem from "../elements/EventCertificateItem.svelte";
  import SettingCertificatesSync from "../elements/SettingCertificatesSync.svelte";
  import { createEventDispatcher } from "svelte";
  import { user } from "$lib/flow/stores";

  /** @type {import('../types').EventSeriesData} */
  export let eventSeries;

  // dispatcher
  const dispatch = createEventDispatcher();

  $: isValid = eventSeries.identifier.host === $user?.addr;

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
    mode = "generate";
    generatePoints = 0;
  }

  async function filterForCertificates(eventObjects) {
    const validEvents = [];
    for (const one of eventObjects) {
      const anyCertVerifier = Object.keys(one.event?.verifiers ?? {}).find(
        (key) =>
          key.endsWith("FLOATChallengeVerifiers.ChallengeAchievementPoint")
      );
      if (anyCertVerifier) {
        const verifier = one.event?.verifiers[anyCertVerifier][0];
        const challengeIdentifier = verifier.challengeIdentifier;
        if (
          challengeIdentifier &&
          challengeIdentifier.host === eventSeries.identifier.host &&
          challengeIdentifier.id === eventSeries.identifier.id
        ) {
          validEvents.push({
            event: one.event,
            points: verifier.challengeThresholdPoints,
          });
        }
      }
    }
    return validEvents;
  }

  $: certificates = Object.values(eventSeries.extra?.Certificates ?? {});
</script>

{#if isValid}
  {#if certificates.length > 0}
    <div class="flex-wrap flex-gap mb-1">
      {#each certificates as one, index (one ? `${one.host}#${one.eventId}@${index}` : "emptySlot#" + index)}
        <EventCertificateItem event={one} points={undefined} />
      {/each}
    </div>
  {/if}
  <details>
    <summary role="button" class="secondary">
      <b>{$t("challenges.detail.settings.cert.title")}</b>
    </summary>
    <div class="grid no-break mb-1">
      <button
        class:secondary={mode !== "generate"}
        class="outline"
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
      <div class="flex flex-col">
        <EventsQuery let:events let:address>
          {#await filterForCertificates(events) then filteredEvents}
            {#if filteredEvents.length > 0}
              <SettingCertificatesSync
                {eventSeries}
                events={filteredEvents}
                on:seriesUpdated={function () {
                  dispatch("seriesUpdated");
                }}
              />
            {:else}
              <p class="text-center">
                {$t("errors.challenges.no-related-cert-float")}
              </p>
            {/if}
          {/await}
        </EventsQuery>
      </div>
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
