<script>
  import { t } from "svelte-i18n";
  import Dialog from "$lib/components/eventseries/elements/Dialog.svelte";
  import EventsPickingTable from "$lib/components/eventseries/table/EventsPickingTable.svelte";
  import EventsQuery from "./EventsQuery.svelte";
  import { createEventDispatcher } from "svelte";

  export let opened = false;

  const dispatch = createEventDispatcher();

  let addressToQuery = "";
  /** @type {{ [key: string]: boolean }} */
  let dialogPicked = {};
  let isNoEventPicked = true;

  $: {
    if (!opened) {
      dialogPicked = {};
    }
  }

  function toggleModal() {
    opened = !opened;
  }

  /**
   * @param {string} host
   * @param {number} eventId
   * @param {boolean} picked
   */
  function onPickChanged(host, eventId, picked) {
    if (host !== addressToQuery) return;
    if (picked) {
      dialogPicked[eventId] = picked;
    } else {
      delete dialogPicked[eventId];
    }
    isNoEventPicked =
      Object.keys(dialogPicked)?.length === 0 ? true : undefined;
  }

  function onAddToSeries() {
    if (isNoEventPicked) return;

    dispatch("add", {
      host: addressToQuery,
      picked: Object.keys(dialogPicked),
    });

    toggleModal();
  }
</script>

<Dialog {opened}>
  <header>
    {$t("challenges.common.dialog.title")}
  </header>
  <EventsQuery
    {opened}
    let:events={pickableEvents}
    let:address
    on:search={function (e) {
      addressToQuery = e.detail.address;
    }}
  >
    <EventsPickingTable
      ownerAddress={addressToQuery || address}
      {pickableEvents}
      on:pickChanged={function (e) {
        onPickChanged(e.detail.host, e.detail.eventId, e.detail.picked);
      }}
    />
  </EventsQuery>
  <footer>
    <!-- svelte-ignore a11y-invalid-attribute -->
    <a
      href="javascript:void(0);"
      role="button"
      class="secondary"
      on:click={toggleModal}
    >
      {$t("common.btn.close")}
    </a>
    <!-- svelte-ignore a11y-invalid-attribute -->
    <a
      href="javascript:void(0);"
      role="button"
      disabled={isNoEventPicked}
      on:click={onAddToSeries}
    >
      {$t("challenges.common.dialog.add-to-challenge")}
    </a>
  </footer>
</Dialog>

<style>
  footer a {
    font-weight: bold;
  }
</style>
