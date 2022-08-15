<script>
  import { t } from "svelte-i18n";
  import { authenticate, createEventSeries } from "$lib/flow/actions";
  import { user, eventSeries } from "$lib/flow/stores";
  import { PAGE_TITLE_EXTENSION } from "$lib/constants";
  import ImageUploader from "$lib/components/ImageUploader.svelte";
  import SeriesCard from "$lib/components/eventseries/SeriesCard.svelte";
  import EventItem from "$lib/components/eventseries/elements/EventItem.svelte";
  import DialogPickingEvents from "$lib/components/eventseries/DialogPickingEvents.svelte";

  // let timezone = new Date()
  //   .toLocaleTimeString("en-us", { timeZoneName: "short" })
  //   .split(" ")[2];
  let dialogOpened = false;

  const creationInProgress = eventSeries.Creation.InProgress;
  const creationStatus = eventSeries.Creation.Status;
  // init with false
  creationInProgress.set(false);
  creationStatus.set(false);

  // For Event Series Creation
  /** @type {import('../../lib/components/eventseries/types').EventSeriesCreateRequest} */
  const draftEventSeries = {
    basics: {
      name: "",
      description: "",
      image: "",
    },
    presetEvents: [],
    emptySlotsAmt: 0,
    emptySlotsAmtRequired: 0,
  };

  $: isPreviewOk =
    !!draftEventSeries.basics.image &&
    !!draftEventSeries.basics.name &&
    !!draftEventSeries.basics.description;

  async function initCreateEventSeries() {
    let canCreateEventSeries = await checkInputs();

    if (!canCreateEventSeries) {
      return;
    }

    createEventSeries(
      draftEventSeries.basics,
      draftEventSeries.presetEvents,
      draftEventSeries.emptySlotsAmt,
      draftEventSeries.emptySlotsAmtRequired
    );
  }

  async function checkInputs() {
    let errorArray = [];
    let messageString = $t("errors.challenges.fields-missing");

    // add conditions here
    if (!draftEventSeries.basics.name) {
      errorArray.push($t("errors.challenges.name-missing"));
    } else if (!draftEventSeries.basics.description) {
      errorArray.push($t("errors.challenges.desc-missing"));
    } else if (!draftEventSeries.basics.image) {
      errorArray.push($t("errors.challenges.image-missing"));
    }

    if (
      draftEventSeries.emptySlotsAmt === 0 &&
      draftEventSeries.presetEvents.length === 0
    ) {
      errorArray.push($t("errors.challenges.slot-required"));
    }

    if (errorArray.length > 0) {
      notifications.info(`${messageString}: ${errorArray.join(",")}`);
      return false;
    } else {
      return true;
    }
  }

  /**
   * events added
   *
   * @param {object} added
   * @param {string} added.host
   * @param {string[]} added.picked
   */
  function onEventsAdded(added) {
    const currentExists = draftEventSeries.presetEvents.reduce((prev, curr) => {
      if (!curr.event) return prev;
      prev.add(`${curr.event.host}#${curr.event.id}`);
      return prev;
    }, new Set());
    const events = added.picked
      .map((one) => ({
        host: added.host,
        id: one,
      }))
      .filter((one) => !currentExists.has(`${one.host}#${one.id}`));

    draftEventSeries.presetEvents = [
      ...draftEventSeries.presetEvents,
      ...events.map((event) => ({
        event,
        required: true,
      })),
    ];
  }

  function onToggleRequired(host, eventId) {
    let slots = draftEventSeries.presetEvents;
    for (let i = 0; i < slots.length; i++) {
      const slot = slots[i];
      if (slot.event?.host === host && slot.event?.id === eventId) {
        slot.required = !slot.required;
        break;
      }
    }
    draftEventSeries.presetEvents = slots;
  }
</script>

<svelte:head>
  <title>
    {$t("challenges.create.head", {
      values: { extension: PAGE_TITLE_EXTENSION },
    })}
  </title>
</svelte:head>

<div class="container">
  <article>
    <h1 class="mb-1 text-center">
      {$t("challenges.common.create")}
    </h1>
    <label for="seriesName">
      {$t("challenges.create.name")}
      <input
        type="text"
        id="seriesName"
        name="seriesName"
        bind:value={draftEventSeries.basics.name}
      />
    </label>

    <label for="seriesDescription">
      {$t("challenges.create.desc")}
      <textarea
        id="seriesDescription"
        name="seriesDescription"
        bind:value={draftEventSeries.basics.description}
      />
    </label>

    <ImageUploader
      on:ipfsAdded={(e) => {
        draftEventSeries.basics.image = e.detail;
      }}
    >
      {$t("challenges.create.image")}
      <SeriesCard
        slot="preview"
        preview={true}
        eventSeriesData={{
          identifier: {
            host: $user?.addr || "0x0000000000",
          },
          basics: draftEventSeries.basics,
          slots: draftEventSeries.presetEvents,
        }}
      />
    </ImageUploader>

    {#if isPreviewOk}
      <h3 class="mb-1 text-center">
        {$t("challenges.create.conifg-title")}
      </h3>

      <hr />

      <h5 class:highlight={draftEventSeries.presetEvents.length > 0}>
        {$t("challenges.create.preset-title")}
      </h5>

      <div class="flex-wrap flex-gap mb-1">
        {#each draftEventSeries.presetEvents as slot (slot.event?.host + slot.event?.id)}
          <EventItem
            item={slot}
            on:clickItem={function (e) {
              onToggleRequired(slot.event?.host, slot.event?.id);
            }}
          />
        {/each}
        <EventItem
          empty={true}
          on:clickEmpty={function (e) {
            dialogOpened = true;
          }}
        />
      </div>

      <hr />

      <h5>{$t("challenges.create.empty-slots-title")}</h5>

      <div class="flex flex-gap mb-1">
        <label for="emptySlotsAmt" class="flex-auto">
          <span class:highlight={draftEventSeries.emptySlotsAmt > 0}>
            {$t("challenges.common.amount")}
          </span>
          <input
            type="number"
            id="emptySlotsAmt"
            name="emptySlotsAmt"
            placeholder={$t("challenges.common.empty-slot-amount")}
            min="0"
            max="25"
            required
            bind:value={draftEventSeries.emptySlotsAmt}
            on:change={function (e) {
              draftEventSeries.emptySlotsAmt = Math.min(
                draftEventSeries.emptySlotsAmt,
                25
              );
            }}
          />
        </label>
        <!-- Range slider -->
        <label for="emptySlotsAmtRequired">
          <span class:highlight={draftEventSeries.emptySlotsAmtRequired > 0}>
            {$t("challenges.common.label-required-slots", {
              values: {
                n: draftEventSeries.emptySlotsAmtRequired ?? "",
              },
            })}
          </span>
          <input
            type="range"
            id="emptySlotsAmtRequired"
            name="emptySlotsAmtRequired"
            min="0"
            max={draftEventSeries.emptySlotsAmt}
            required
            bind:value={draftEventSeries.emptySlotsAmtRequired}
          />
        </label>
      </div>
    {/if}

    <footer>
      {#if !$user?.loggedIn}
        <div class="mt-2 mb-2">
          <button class="contrast small-button" on:click={authenticate}>
            {$t("common.btn.connectWallet")}
          </button>
        </div>
      {:else if $creationInProgress}
        <button aria-busy="true" disabled>
          {$t("common.hint.please-wait-for-tx")}
        </button>
      {:else if $creationStatus.success}
        <a
          role="button"
          class="d-block"
          href="/{$user?.addr}/?tab=challenges"
          style="display:block"
        >
          {$t("common.hint.action-successful", {
            values: {
              what: "Challenge",
              action: "created",
            },
          })}
        </a>
      {:else if !$creationStatus.success && $creationStatus.error}
        <button class="error" disabled>
          {$creationStatus.error}
        </button>
      {:else}
        <button
          on:click|preventDefault={initCreateEventSeries}
          disabled={!isPreviewOk}
        >
          {#if isPreviewOk}
            {$t("challenges.create.button")}
          {:else}
            {$t("common.hint.incomplete-params")}
          {/if}
        </button>
      {/if}
    </footer>
  </article>
</div>

<DialogPickingEvents
  bind:opened={dialogOpened}
  on:add={function (e) {
    onEventsAdded(e.detail);
  }}
/>

<style>
  .highlight {
    color: var(--primary);
  }
</style>
