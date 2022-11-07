<script>
  import { t } from "svelte-i18n";
  import Loading from "$lib/components/common/Loading.svelte";
  import { createEventDispatcher } from "svelte";
  import { getEvents, resolveAddressObject } from "$lib/flow/actions";

  export let opened = false;

  const dispatch = createEventDispatcher();

  let addressToQuery = "";
  let addressToQueryValid = undefined;
  let addressIsQuerying = false;
  /** @type {Promise<import('$lib/components/eventseries/types').FloatEvent[]>} */
  let floatEventLoadingPromise = null;

  $: {
    if (!opened) {
      addressToQuery = "";
      addressToQueryValid = undefined;
    }
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
    dispatch("search", { address: addrObj.address });
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
</script>

<div class="flex-wrap flex-gap" style="width: 100%;">
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
    style="margin-top: 10px; font-weight: bold;"
    aria-busy={addressIsQuerying}
    on:click={onSearchAddress}
  >
    {$t("challenges.common.dialog.btn-query")}
  </a>
</div>
{#if addressToQueryValid && floatEventLoadingPromise}
  {#await floatEventLoadingPromise}
    <Loading />
  {:then pickableEvents}
    {#if pickableEvents.length > 0}
      <slot events={pickableEvents} address={addressToQuery} />
    {:else}
      <p class="text-center">
        {$t("errors.events.account-no-events")}
      </p>
    {/if}
  {/await}
{/if}
