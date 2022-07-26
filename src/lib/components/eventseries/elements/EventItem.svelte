<script>
  import { createEventDispatcher } from "svelte";
  import { user } from "$lib/flow/stores";
  import { resolveAddressObject, getEvent } from "$lib/flow/actions";
  import Loading from "$lib/components/common/Loading.svelte";

  // dispatcher
  const dispatch = createEventDispatcher();

  // For empty part
  export let empty = false;

  // for none empty part
  export let preview = true;
  /** @type {import('../types').EventSeriesSlot} */
  export let item = { event: null, required: false };

  $: itemRequired = item.required ?? false;
  $: itemOwned = false;

  /** @type {Promise<import('./types').FloatEvent>} */
  const floatEventCallback = async () => {
    if (!item.event) return null;

    let hostAddress;
    if (item.event?.host.startsWith("0x")) {
      hostAddress = item.event?.host;
    } else {
      let resolvedNameObject = await resolveAddressObject(item.event?.host);
      hostAddress = resolvedNameObject.address;
    }
    let eventData = await getEvent(hostAddress, String(item.event?.id));
    if (!eventData) {
      return null;
    }
    if (!preview) {
      itemOwned = false; // FIXME: use ownedIdsFromEvent to check FLOAT
    }
    return eventData;
  };

  const handleClick = (e) => {
    if (!empty) {
      if (item.event) {
        dispatch("clickItem", {
          host: item.event?.host,
          id: item.event?.id,
        });
      }
    } else {
      dispatch("clickEmpty", e.detail);
    }
  };
</script>

<article class="card-item" on:click={handleClick}>
  {#if !empty}
    {#await floatEventCallback()}
      <Loading />
    {:then floatEvent}
      <div>
        {#if !floatEvent}
          <h3>Empty<br />Slot</h3>
        {:else}
          <img
            src="https://ipfs.infura.io/ipfs/{floatEvent.image}"
            alt="{floatEvent.name} Image"
            class:unclaimed={!preview}
          />
          <a
            class="no-style"
            href="/{item.event?.host}/event/{floatEvent.eventId}"
            target="_blank"
            data-tooltip="#{floatEvent.eventId} by {item.event?.host}"
          >
            <h3>{floatEvent.name}</h3>
          </a>
        {/if}
      </div>
    {/await}
  {:else}
    <div class="center pointer" on:click={handleClick}>
      <svg
        xmlns="http://www.w3.org/2000/svg"
        viewBox="0 0 20 20"
        fill="currentColor"
      >
        <path
          fill-rule="evenodd"
          d="M10 3a1 1 0 011 1v5h5a1 1 0 110 2h-5v5a1 1 0 11-2 0v-5H4a1 1 0 110-2h5V4a1 1 0 011-1z"
          clip-rule="evenodd"
        />
      </svg>
    </div>
  {/if}

  {#if !empty}
    {#if itemOwned}
      <svg class="badge" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20">
        <path
          fill-rule="evenodd"
          d="M6.267 3.455a3.066 3.066 0 001.745-.723 3.066 3.066 0 013.976 0 3.066 3.066 0 001.745.723 3.066 3.066 0 012.812 2.812c.051.643.304 1.254.723 1.745a3.066 3.066 0 010 3.976 3.066 3.066 0 00-.723 1.745 3.066 3.066 0 01-2.812 2.812 3.066 3.066 0 00-1.745.723 3.066 3.066 0 01-3.976 0 3.066 3.066 0 00-1.745-.723 3.066 3.066 0 01-2.812-2.812 3.066 3.066 0 00-.723-1.745 3.066 3.066 0 010-3.976 3.066 3.066 0 00.723-1.745 3.066 3.066 0 012.812-2.812zm7.44 5.252a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
          clip-rule="evenodd"
        />
      </svg>
    {:else if itemRequired}
      <svg
        class="badge outline opacity"
        xmlns="http://www.w3.org/2000/svg"
        viewBox="0 0 24 24"
      >
        <path
          stroke-linecap="round"
          stroke-linejoin="round"
          d="M9 12l2 2 4-4M7.835 4.697a3.42 3.42 0 001.946-.806 3.42 3.42 0 014.438 0 3.42 3.42 0 001.946.806 3.42 3.42 0 013.138 3.138 3.42 3.42 0 00.806 1.946 3.42 3.42 0 010 4.438 3.42 3.42 0 00-.806 1.946 3.42 3.42 0 01-3.138 3.138 3.42 3.42 0 00-1.946.806 3.42 3.42 0 01-4.438 0 3.42 3.42 0 00-1.946-.806 3.42 3.42 0 01-3.138-3.138 3.42 3.42 0 00-.806-1.946 3.42 3.42 0 010-4.438 3.42 3.42 0 00.806-1.946 3.42 3.42 0 013.138-3.138z"
        />
      </svg>
    {/if}
  {/if}
</article>

<style>
  .card-item {
    position: relative;

    width: 96px;
    height: 128px;

    padding: 8px;
    margin: 0 4px 4px 0;

    border: 1px solid transparent;
  }

  .card-item:hover {
    border: 1px solid var(--primary);
  }

  .card-item > div > * {
    max-width: 80px;
    max-height: 80px;
  }

  .card-item > div {
    display: flex;
    flex-direction: column;
    justify-content: end;
    align-items: center;
    text-align: center;

    width: 100%;
    height: 100%;
  }
  .card-item > div.pointer {
    cursor: pointer;
  }

  .card-item > div.center {
    justify-content: center;
  }

  .card-item > div.center > svg {
    width: 64px;
    height: 64px;
  }

  .card-item h3 {
    font-size: 0.8rem;
    flex-grow: 1;

    text-overflow: ellipsis;
    overflow: hidden;
    white-space: nowrap;
  }

  .card-item img {
    display: block;
    margin: 0 auto;
    margin-bottom: 6px;
  }

  .card-item .badge {
    cursor: pointer;
    position: absolute;
    top: -4px;
    right: -4px;
    width: 1rem;
    height: 1rem;
    fill: var(--primary);
  }

  .card-item .badge.outline {
    fill: var(--background-color);
    stroke: var(--primary);
    stroke-width: 2;
  }

  .card-item .badge.opacity {
    fill-opacity: 0.3;
    stroke-opacity: 0.3;
  }

  .unclaimed {
    filter: grayscale(0);
    opacity: 0.4;
  }
</style>
