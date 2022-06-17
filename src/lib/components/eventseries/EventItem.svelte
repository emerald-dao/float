<script>
  import { user } from "$lib/flow/stores";
  import { resolveAddressObject, getEvent } from "$lib/flow/actions";
  import { getResolvedName } from "$lib/flow/utils";
  import Loading from "../common/Loading.svelte";
  import { createEventDispatcher } from "svelte";
  // dispatcher
  const dispatch = createEventDispatcher();

  // For empty part
  export let empty = false;

  // for none empty part
  /** @type {string} */
  export let host = "";
  /** @type {number} */
  export let eventId = -1;
  export let preview = true;
  export let required = true;

  /** @type {string} */
  let resolvedName;

  /** @type {Promise<import('./types').FloatEvent>} */
  const floatEventCallback = async () => {
    let resolvedNameObject = await resolveAddressObject(host);
    resolvedName = getResolvedName(resolvedNameObject);
    let eventData = await getEvent(resolvedNameObject.address, String(eventId));
    if (!eventData) {
      return null;
    }
    let data = { ...eventData };
    if (!preview) {
      data.hasClaimed = await hasClaimedEvent(
        resolvedNameObject.address,
        eventId,
        $user.addr
      );
    }
    return data;
  };
</script>

{#if !empty && host !== "" && eventId > 0}
  {#await floatEventCallback()}
    <Loading />
  {:then floatEvent}
    <article class="card-item">
      {#if !floatEvent}
        <h3>Deleted</h3>
      {:else}
        <img
          src="https://ipfs.infura.io/ipfs/{floatEvent.image}"
          alt="{floatEvent.name} Image"
          class:unclaimed={!preview}
        />
        <a
          class="no-style"
          href="/{resolvedName}/event/{floatEvent.eventId}"
          target="_blank"
          data-tooltip="#{floatEvent.eventId} By {resolvedName}"
        >
          <h3>{floatEvent.name}</h3>
        </a>
        {#if required}
          <svg
            class="badge"
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 20 20"
            fill="currentColor"
          >
            <path
              fill-rule="evenodd"
              d="M6.267 3.455a3.066 3.066 0 001.745-.723 3.066 3.066 0 013.976 0 3.066 3.066 0 001.745.723 3.066 3.066 0 012.812 2.812c.051.643.304 1.254.723 1.745a3.066 3.066 0 010 3.976 3.066 3.066 0 00-.723 1.745 3.066 3.066 0 01-2.812 2.812 3.066 3.066 0 00-1.745.723 3.066 3.066 0 01-3.976 0 3.066 3.066 0 00-1.745-.723 3.066 3.066 0 01-2.812-2.812 3.066 3.066 0 00-.723-1.745 3.066 3.066 0 010-3.976 3.066 3.066 0 00.723-1.745 3.066 3.066 0 012.812-2.812zm7.44 5.252a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
              clip-rule="evenodd"
            />
          </svg>
        {/if}
      {/if}
    </article>
  {/await}
{:else}
  <article class="card-item center">
    <svg
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 20 20"
      fill="currentColor"
      on:click={(e) => dispatch("clickEmpty", e.detail)}
    >
      <path
        fill-rule="evenodd"
        d="M10 3a1 1 0 011 1v5h5a1 1 0 110 2h-5v5a1 1 0 11-2 0v-5H4a1 1 0 110-2h5V4a1 1 0 011-1z"
        clip-rule="evenodd"
      />
    </svg>
  </article>
{/if}

<style>
  .card-item {
    position: relative;

    width: 96px;
    min-height: 128px;
    max-height: 95%;

    padding: 8px;
    margin: 0 4px 4px 0;

    display: flex;
    flex-direction: column;
    justify-content: end;
    align-items: center;
    text-align: center;

    border: 1px solid transparent;
  }

  .card-item:hover {
    border: 1px solid var(--primary);
  }

  .card-item > * {
    max-width: 80px;
    max-height: 80px;
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
    position: absolute;
    top: -4px;
    right: -4px;
    width: 1rem;
    height: 1rem;
    fill: var(--primary);
  }

  .card-item.center {
    justify-content: center;
  }

  .card-item.center > svg {
    width: 64px;
    height: 64px;
    cursor: pointer;
  }

  .unclaimed {
    filter: grayscale(0);
    opacity: 0.4;
  }
</style>
