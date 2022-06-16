<script>
  import { user, eventSeries } from "$lib/flow/stores";
  import { draftEventSeries } from "$lib/stores";
  import { PAGE_TITLE_EXTENSION } from "$lib/constants";
  import ImageUploader from "$lib/components/ImageUploader.svelte";
  import { createEventSeries } from "$lib/flow/actions";
  import SeriesCard from "$lib/components/eventseries/SeriesCard.svelte";

  let timezone = new Date()
    .toLocaleTimeString("en-us", { timeZoneName: "short" })
    .split(" ")[2];

  async function initCreateEventSeries() {
    let canCreateEventSeries = await checkInputs();

    if (!canCreateEventSeries) {
      return;
    }

    createEventSeries(
      $draftEventSeries.basics,
      $draftEventSeries.presetEvents,
      $draftEventSeries.emptySlotsAmt,
      $draftEventSeries.emptySlotsRequired
    );
  }

  async function checkInputs() {
    return true;
  }
</script>

<svelte:head>
  <title>Create a new FLOAT Series {PAGE_TITLE_EXTENSION}</title>
</svelte:head>

<div class="container">
  <article>
    <h1 class="mb-1 text-center">Create a new Event Series</h1>
    <label for="name">
      Event Series Name
      <input
        type="text"
        id="name"
        name="name"
        bind:value={$draftEventSeries.basics.name}
      />
    </label>

    <label for="description">
      Event Series Description
      <textarea
        id="description"
        name="description"
        bind:value={$draftEventSeries.basics.description}
      />
    </label>

    <ImageUploader
      on:ipfsAdded={(e) => {
        $draftEventSeries.basics.image = e.detail;
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
          basics: $draftEventSeries.basics,
          slots: $draftEventSeries.presetEvents,
        }}
      />
    </ImageUploader>

    <h3 class="mb-1 text-center">Configure your Event Series</h3>

    <!-- TODO -->
  </article>
</div>

<style>
  .text-center {
    text-align: center;
  }
</style>
