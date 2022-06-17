<script>
  import { authenticate, createEventSeries } from "$lib/flow/actions";
  import { user, eventSeries } from "$lib/flow/stores";
  import { PAGE_TITLE_EXTENSION } from "$lib/constants";
  import ImageUploader from "$lib/components/ImageUploader.svelte";
  import SeriesCard from "$lib/components/eventseries/SeriesCard.svelte";
  import EventItem from "$lib/components/eventseries/EventItem.svelte";

  let timezone = new Date()
    .toLocaleTimeString("en-us", { timeZoneName: "short" })
    .split(" ")[2];

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

  $: isPreviewOk = true;
  // !!draftEventSeries.basics.image &&
  // !!draftEventSeries.basics.name &&
  // !!draftEventSeries.basics.description;

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
    // FIXME required inputs checking
    return true;
  }

  function onClickEmptySlot() {
    // TODO
  }
</script>

<svelte:head>
  <title>Create a new Event Series {PAGE_TITLE_EXTENSION}</title>
</svelte:head>

<div class="container">
  <article>
    <h1 class="mb-1 text-center">Create a new Event Series</h1>
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

      <h5>Empty Slots (to configure later)</h5>

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

      <hr />

      <h5>Preset Slots</h5>

      <div class="flex-wrap flex-gap">
        <!-- 97505692 97506358 -->
        {#each draftEventSeries.presetEvents as slot}
          <EventItem
            host={slot.host}
            eventId={slot.eventId}
            required={slot.required}
          />
        {/each}
        <EventItem host={$user?.addr} eventId={97506358} />
        <EventItem empty={true} on:clickEmpty={onClickEmptySlot} />
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

<style>
  .flex-wrap {
    display: flex;
    flex-wrap: wrap;
    justify-content: flex-start;
    align-items: stretch;
  }

  .flex-gap {
    gap: 1rem;
  }

  .flex-none {
    flex: none;
  }

  .flex-auto {
    flex: 1 1 auto;
  }

  .fix-form {
    padding: 15px 0px;
  }

  .highlight {
    color: var(--primary);
  }
</style>
