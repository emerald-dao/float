<script>
  import { page } from "$app/stores";
  import {
    user
  } from "$lib/flow/stores";
  import { PAGE_TITLE_EXTENSION } from "$lib/constants";
  import {
    getEvent,
    toggleClaimable,
    toggleTransferrable,
    deleteEvent,
    hasClaimedEvent
  } from "$lib/flow/actions.js";

  import IntersectionObserver from 'svelte-intersection-observer';

  import Loading from "$lib/components/common/Loading.svelte";
  import Float from "$lib/components/Float.svelte";
  import Meta from "$lib/components/common/Meta.svelte";

  import ClaimsTable from '$lib/components/common/table/ClaimsTable.svelte';
  import ClaimButton from "$lib/components/ClaimButton.svelte";

  let claimsTableInView;

  const floatEventCallback = async () => {
    let eventData = await getEvent($page.params.address, $page.params.eventId);
    let hasClaimed = await hasClaimedEvent($page.params.address, $page.params.eventId, $user.addr);
    let data = {...eventData, hasClaimed};
    return data;
  }

  let floatEvent = floatEventCallback();
</script>

<svelte:head>
  <title>FLOAT #{$page.params.eventId} {PAGE_TITLE_EXTENSION}</title>
</svelte:head>

<div class="container">
  {#await floatEvent}
    <Loading />
  {:then floatEvent}
    <Meta
      title="{floatEvent?.name} | FLOAT #{$page.params.eventId}"
      author={floatEvent?.host}
      description={floatEvent?.description}
      url={$page.url}
    />

    <article>
      <header>
        <a href={floatEvent?.url} target="_blank">
          <h1>{floatEvent?.name}</h1>
        </a>
        <p>FLOAT Event #{$page.params.eventId}</p>
        <p>
          <small class="muted"
            >Created on {new Date(
              floatEvent?.dateCreated * 1000
            ).toLocaleString()}</small
          >
        </p>
      </header>
      {#if floatEvent?.hasClaimed}
        <div class="claimed-badge">✓ You claimed this FLOAT</div>
        <Float
          float={{
            eventHost: floatEvent?.host,
            eventId: floatEvent?.eventId,
            eventImage: floatEvent?.image,
            eventName: floatEvent?.name,
            eventMetadata: {
              totalSupply: floatEvent?.totalSupply,
            },
            serial: floatEvent?.hasClaimed.serial,
          }}
          individual={true}
        />
    
      {:else}
        <Float
          float={{
            eventHost: floatEvent?.host,
            eventId: floatEvent?.eventId,
            eventImage: floatEvent?.image,
            eventName: floatEvent?.name,
            eventMetadata: {
              totalSupply: floatEvent?.totalSupply,
            },
          }}
          preview={true}
          individual={false}
        />
      {/if}

      <blockquote>
        <strong><small class="muted">DESCRIPTION</small></strong><br
        />{floatEvent?.description}
      </blockquote>
      <p>
        <span class="emphasis">{floatEvent?.totalSupply}</span> have been minted.
      </p>
      
      {#if floatEvent?.verifiers["A.0afe396ebc8eee65.FLOATVerifiers.Limited"]}
        <p>
          Only <span class="emphasis">{floatEvent?.verifiers["A.0afe396ebc8eee65.FLOATVerifiers.Limited"].capacity}</span> will ever exist.
        </p>
      {/if}
      <footer>

        <ClaimButton floatEvent={floatEvent} hasClaimed={floatEvent?.hasClaimed} />
        
        {#if $user?.addr == floatEvent?.host}
          <div class="toggle">
            <button
              class="outline"
              on:click={() => toggleClaimable(floatEvent?.eventId)}
            >
              {floatEvent?.claimable ? "Pause claiming" : "Resume claiming"}
            </button>
            <button
              class="outline"
              on:click={() => toggleTransferrable(floatEvent?.eventId)}
            >
              {floatEvent?.transferrable ? "Stop transfers" : "Allow transfers"}
            </button>
            <button
              class="outline red"
              disabled={floatEvent?.totalSupply !== 0}
              on:click={() => deleteEvent(floatEvent?.eventId)}
            >
              Delete this event
            </button>
          </div>
        {/if}
      </footer>
    </article>

    <article>
      <header>
        <h3>Owned by</h3>
      </header>
      <IntersectionObserver
        once
        element={claimsTableInView}
        let:intersecting
        
      >
      <div bind:this={claimsTableInView}>
        {#if intersecting}
          <ClaimsTable address={floatEvent?.host} eventId={floatEvent?.eventId} />
        {/if}
      </div>
      </IntersectionObserver>
    </article>
  {/await}

</div>

<style>
  .container {
    text-align: center;
  }
  blockquote {
    text-align: left;
  }

  .secondary.outline {
    font-weight: 300;
  }

  p {
    margin-bottom: 0px;
  }

  .muted {
    font-size: 0.7rem;
    opacity: 0.7;
  }

  .toggle {
    margin-top: 15px;
    margin-bottom: 0px;
    position: relative;
    display: flex;
    justify-content: space-around;
    height: auto;
  }

  .toggle button {
    width: 30%;
  }

  .small {
    position: relative;
    width: 125px;
    font-size: 13px;
    padding: 5px;
    left: 50%;
    transform: translateX(-50%);
  }

  .error {
    background-color: red;
    border-color: white;
    color: white;
    opacity: 1;
  }

  .claimed-badge {
    width:250px;
    margin: 0 auto;
    padding: 0.3rem 0.5rem;
    border: 1px solid var(--green);
    border-radius: 100px;
    color: var(--green);
    font-size: 0.7rem;
  }

  .claims {
    text-align:left;
  }

</style>
