<script>
  import { t } from "svelte-i18n";
  import { getEvents, resolveAddressObject } from "$lib/flow/actions";
  import Dialog from "$lib/components/eventseries/elements/Dialog.svelte";
  import EventsPickingTable from "$lib/components/eventseries/table/EventsPickingTable.svelte";
  import Loading from "$lib/components/common/Loading.svelte";
  import { createEventDispatcher } from "svelte";

  export let opened = false;

  let addressToQuery = "";
  /** @type {{ [key: string]: boolean }} */
  let dialogPicked = {};
  let isNoEventPicked = true;

  let addressToQueryValid = undefined;
  let addressIsQuerying = false;
  /** @type {Promise<import('$lib/components/eventseries/types').FloatEvent[]>} */
  let floatEventLoadingPromise = null;

  $: {
    if (!opened) {
      addressToQuery = "";
      dialogPicked = {};
      addressToQueryValid = undefined;
    }
  }

  const dispatch = createEventDispatcher();

  function toggleModal() {
    opened = !opened;
  }

  async function onSearchAddress() {
    floatEventLoadingPromise = null;
    addressIsQuerying = true;
    const addrObj = await resolveAddressObject(addressToQuery);
    addressIsQuerying = false;
    addressToQueryValid = addrObj.address !== "";
    if (!addressToQueryValid && addressToQuery !== addrObj.address) {
      addressToQuery = addrObj.address;
    }
    floatEventLoadingPromise = getFLOATEvents(addrObj.address);
  }

  /**
   * @param address
   * @return {Promise<import('$lib/components/eventseries/types').FloatEvent[]>}
   */
  async function getFLOATEvents(address) {
    const rawEvents = await getEvents(address);
    if (rawEvents && Object.keys(rawEvents)?.length > 0) {
      return Object.values(rawEvents).map((one) => ({
        event: one,
        picked: false,
      }));
    } else {
      return [];
    }
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
  <div class="flex flex-gap">
    <label for="seriesName" class="flex-auto">
      {$t("challenges.common.dialog.label-owner")}
      <input
        type="text"
        id="addressToQuery"
        name="addressToQuery"
        placeholder="0x00000000000"
        on:keyup={function () {
          addressToQueryValid = undefined;
        }}
        bind:value={addressToQuery}
        aria-invalid={typeof addressToQueryValid === "boolean"
          ? !addressToQueryValid
          : undefined}
      />
    </label>
    <!-- svelte-ignore a11y-invalid-attribute -->
    <a
      href="javascript:void(0);"
      role="button"
      class="flex-none"
      style="margin-top: 10px;"
      aria-busy={addressIsQuerying}
      on:click={onSearchAddress}
    >
      {$t("challenges.common.dialog.btn-query")}
    </a>
  </div>
  {#if addressToQueryValid && floatEventLoadingPromise}
    <hr />
    {#await floatEventLoadingPromise}
      <Loading />
    {:then pickableEvents}
      {#if pickableEvents.length > 0}
        <EventsPickingTable
          ownerAddress={addressToQuery}
          {pickableEvents}
          on:pickChanged={function (e) {
            onPickChanged(e.detail.host, e.detail.eventId, e.detail.picked);
          }}
        />
      {:else}
        <p class="text-center">
          {$t("errors.events.account-no-events")}
        </p>
      {/if}
    {/await}
  {/if}
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
