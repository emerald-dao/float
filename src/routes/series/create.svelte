<script>
  import { authenticate, createEventSeries } from "$lib/flow/actions";
  import { user, eventSeries } from "$lib/flow/stores";
  import { PAGE_TITLE_EXTENSION } from "$lib/constants";
  import ImageUploader from "$lib/components/ImageUploader.svelte";
  import SeriesCard from "$lib/components/eventseries/SeriesCard.svelte";
  import EventItem from "$lib/components/eventseries/EventItem.svelte";
  import DialogPickingEvents from "$lib/components/eventseries/DialogPickingEvents.svelte";

  let timezone = new Date()
    .toLocaleTimeString("en-us", { timeZoneName: "short" })
    .split(" ")[2];
  let dialogOpened = false;

  const creationInProgress = eventSeries.Creation.InProgress;
  const creationStatus = eventSeries.Creation.Status;

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
    emptySlotsRequired: false,
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
      draftEventSeries.emptySlotsRequired
    );
  }

  async function checkInputs() {
    let errorArray = [];
    let messageString = "The following mandatory fields are missing";

    // add conditions here
    if (!draftEventSeries.basics.name) {
      errorArray.push("EventSeries Name");
    } else if (!draftEventSeries.basics.description) {
      errorArray.push("EventSeries Description");
    } else if (!draftEventSeries.basics.image) {
      errorArray.push("EventSeries Image");
    }

    if (
      draftEventSeries.emptySlotsAmt === 0 &&
      draftEventSeries.presetEvents.length === 0
    ) {
      errorArray.push("EventSeries need one slot at least.");
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
    draftEventSeries.presetEvents = [
      ...draftEventSeries.presetEvents,
      ...added.picked.map((one) => ({
        host: added.host,
        eventId: one,
        required: true,
      })),
    ];
  }

  function onToggleRequired(host, eventId) {
    let slots = draftEventSeries.presetEvents;
    for (let i = 0; i < slots.length; i++) {
      const slot = slots[i];
      if (slot.host === host && slot.eventId === eventId) {
        slot.required = !slot.required;
        break;
      }
    }
    draftEventSeries.presetEvents = slots;
  }
</script>

<svelte:head>
  <title>Create a new Event Series {PAGE_TITLE_EXTENSION}</title>
</svelte:head>

<div class="container">
  <article>
    <h1 class="mb-1 text-center">Create a new FLOAT Event Series</h1>
    <label for="seriesName">
      Event Series Name
      <input
        type="text"
        id="seriesName"
        name="seriesName"
        bind:value={draftEventSeries.basics.name}
      />
    </label>

    <label for="seriesDescription">
      Event Series Description
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
      Event Series Image
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
      <h3 class="mb-1 text-center">Configure your Event Series</h3>

      <hr />

      <h5>Preset FLOAT Slots</h5>

      <div class="flex-wrap flex-gap mb-1">
        {#each draftEventSeries.presetEvents as slot (slot.host + slot.eventId)}
          <EventItem
            item={slot}
            on:clickItem={(e) => onToggleRequired(slot.host, slot.eventId)}
          />
        {/each}
        <EventItem empty={true} on:clickEmpty={(e) => (dialogOpened = true)} />
      </div>

      <hr />

      <h5>Empty FLOAT Slots (to configure later)</h5>

      <div class="flex flex-gap mb-1">
        <label for="emptySlotsAmt" class="flex-auto">
          Amount
          <input
            type="number"
            id="emptySlotsAmt"
            name="emptySlotsAmt"
            placeholder="Empty Slot Amount"
            min="0"
            max="25"
            required
            bind:value={draftEventSeries.emptySlotsAmt}
            on:change={(e) => {
              draftEventSeries.emptySlotsAmt = Math.min(
                draftEventSeries.emptySlotsAmt,
                25
              );
            }}
          />
        </label>
        <fieldset class="flex-none">
          <legend>Property</legend>
          <label for="emptySlotsRequired" class="fix-form">
            <input
              type="checkbox"
              role="switch"
              id="emptySlotsRequired"
              name="emptySlotsRequired"
              required
              bind:checked={draftEventSeries.emptySlotsRequired}
            />
            <span class:highlight={draftEventSeries.emptySlotsRequired}>
              Event required
            </span>
          </label>
        </fieldset>
      </div>
    {/if}

    <footer>
      {#if !$user?.loggedIn}
        <div class="mt-2 mb-2">
          <button class="contrast small-button" on:click={authenticate}
            >Connect Wallet</button
          >
        </div>
      {:else if $creationInProgress}
        <button aria-busy="true" disabled>Creating FLOAT</button>
      {:else if $creationStatus.success}
        <a
          role="button"
          class="d-block"
          href="/series/{$user?.addr}/"
          style="display:block"
        >
          Event Series created successfully!
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
            Create Event Series
          {:else}
            Incomplete parameters
          {/if}
        </button>
      {/if}
    </footer>
  </article>
</div>

<DialogPickingEvents
  bind:opened={dialogOpened}
  on:add={(e) => onEventsAdded(e.detail)}
/>

<style>
  .fix-form {
    padding: 15px 0px;
  }

  .highlight {
    color: var(--primary);
  }
</style>
