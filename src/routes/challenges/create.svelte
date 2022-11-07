<script>
  import { t } from "svelte-i18n";
  import { authenticate, createEventSeries, canCreateNewChallenge } from "$lib/flow/actions";
  import { user, eventSeries } from "$lib/flow/stores";
  import { PAGE_TITLE_EXTENSION } from "$lib/constants";
  import { notifications } from "$lib/notifications";
  import Loading from "$lib/components/common/Loading.svelte";
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
    emptySlots: [],
  };

  let totalSlots = 0;
  let totalPrimarySlots = 0;

  $: isPreviewOk =
    !!draftEventSeries.basics.image &&
    !!draftEventSeries.basics.name &&
    !!draftEventSeries.basics.description;

  $: presetPrimaryAmt = draftEventSeries.presetEvents.filter(
    (one) => one.required
  ).length;
  $: {
    const presetRequired = draftEventSeries.presetEvents.filter(
      (one) => one.required
    ).length;
    const emptyRequired = Math.max(totalPrimarySlots - presetRequired, 0);
    const initIndex = draftEventSeries.presetEvents.length;
    let slots = [];
    for (let i = initIndex; i < totalSlots; i++) {
      slots.push({ event: null, required: i < initIndex + emptyRequired });
    }
    draftEventSeries.emptySlots = slots;
  }

  async function canCreateNew(address) {
    return await canCreateNewChallenge(address)
  }

  async function initCreateEventSeries() {
    let canCreateEventSeries = await checkInputs();

    if (!canCreateEventSeries) {
      return;
    }

    createEventSeries(
      draftEventSeries.basics,
      draftEventSeries.presetEvents,
      totalSlots - draftEventSeries.presetEvents.length,
      totalPrimarySlots - presetPrimaryAmt
    );
  }

  async function checkInputs() {
    let errorArray = [];
    let messageString = $t("errors.common.fields-missing");

    // add conditions here
    if (!draftEventSeries.basics.name) {
      errorArray.push($t("errors.challenges.name-missing"));
    }
    if (!draftEventSeries.basics.description) {
      errorArray.push($t("errors.challenges.desc-missing"));
    }
    if (!draftEventSeries.basics.image) {
      errorArray.push($t("errors.challenges.image-missing"));
    }

    if (totalSlots === 0 && draftEventSeries.presetEvents.length === 0) {
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

    // update primary slots
    totalPrimarySlots = Math.min(totalSlots, totalPrimarySlots + events.length);
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
  {#if !$user?.loggedIn}
  <div class="mt-2 mb-2">
    <button class="contrast small-button" on:click={authenticate}>
      {$t("common.btn.connectWallet")}
    </button>
  </div>
  {:else}
    {#await canCreateNew($user?.addr)}
      <Loading />
    {:then canCreate}
    {#if !canCreate}
      <div class="text-center">
        <p>
          { $t('challenges.create.hint-ecpass-1') }
        </p>
        <p>
          { $t('challenges.create.hint-ecpass-2') }
          <a href="https://pass.ecdao.org/" target="_blank">Emerald Pass</a>
        </p>
      </div>
    {:else}
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

      <h5>{$t("challenges.create.empty-slots-title")}</h5>
      <div class="flex flex-gap mb-1">
        <label for="totalSlots" class="flex-auto">
          <span class:highlight={totalSlots > 0}>
            {$t("challenges.common.amount")}
          </span>
          <input
            type="number"
            id="totalSlots"
            name="totalSlots"
            min={totalPrimarySlots}
            max="50"
            required
            bind:value={totalSlots}
            on:change={function (e) {
              totalSlots = Math.max(
                Math.max(
                  draftEventSeries.presetEvents.length,
                  Math.min(totalSlots, 50)
                ),
                totalPrimarySlots
              );
            }}
          />
        </label>
        <!-- Range slider -->
        <label for="totalPrimarySlots">
          <span class:highlight={totalPrimarySlots > 0}>
            {$t("challenges.common.label-primary-slots", {
              values: {
                n: totalPrimarySlots ?? "",
              },
            })}
          </span>
          <input
            type="range"
            id="totalPrimarySlots"
            name="totalPrimarySlots"
            min={presetPrimaryAmt}
            max={totalSlots}
            required
            bind:value={totalPrimarySlots}
          />
        </label>
      </div>

      {#if totalSlots > 0}
        <hr />

        <h5>
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
          {#each draftEventSeries.emptySlots as slot, index (`empty_${index}`)}
            <EventItem
              item={slot}
              empty={true}
              on:clickEmpty={function (e) {
                dialogOpened = true;
              }}
            />
          {/each}
        </div>
      {/if}
    {/if}

    <footer>
      {#if $creationInProgress}
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
              what: $t("challenges.common.name"),
              action: $t("common.action.created"),
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
    {/if}
    {/await}
  {/if}
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
