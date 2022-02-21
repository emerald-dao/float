<script>
  import { page } from "$app/stores";
  import {
    floatClaimedStatus,
    floatClaimingInProgress,
    user,
  } from "$lib/flow/stores";
  import { PAGE_TITLE_EXTENSION } from "$lib/constants";
  import {
    getEvent,
    claimFLOAT,
    toggleClaimable,
    toggleTransferrable,
    deleteEvent,
    hasClaimedEvent,
  } from "$lib/flow/actions.js";

  import IntersectionObserver from 'svelte-intersection-observer';

  import Loading from "$lib/components/common/Loading.svelte";
  import Float from "$lib/components/Float.svelte";
  import Countdown from "$lib/components/common/Countdown.svelte";
  import Meta from "$lib/components/common/Meta.svelte";

  import ClaimsTable from '$lib/components/common/table/ClaimsTable.svelte';
  let claimsTableInView;

  const floatEventCallback = async () => {
    let eventData = await getEvent($page.params.address, $page.params.eventId);
    let hasClaimed = await hasClaimedEvent($page.params.address, $page.params.eventId, $user.addr);

    console.log({...eventData, hasClaimed});
    return {...eventData, hasClaimed};
  }

  let floatEvent = floatEventCallback();

  let claimCode = "";

  $: currentUnixTime = +new Date() / 1000;
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
            eventId: floatEvent?.id,
            eventMetadata: {
              name: floatEvent?.name,
              image: floatEvent?.image,
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
            eventId: floatEvent?.id,
            eventMetadata: {
              name: floatEvent?.name,
              image: floatEvent?.image,
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
      {#if floatEvent?.capacity}
        <p>
          Only <span class="emphasis">{floatEvent.capacity}</span> will ever exist.
        </p>
      {/if}
      <footer>
        <!-- 
        Possible cases:
        - not claimable -> host needs to manually assign
        - claimable
          - secret code -> Add secrete code + "Claim"
          - no secret code -> "Claim"
        - claimable and not open
          - time not started -> "Claimable in .... days"
          - time expired -> "This FLOAT is closed"
          - capacity reached -> "This FLOAT is closed. All 1000/1000 have been claimed"
      -->

        {#if floatEvent?.hasClaimed}
          <button class="secondary outline" disabled>
            ✓ You already claimed this FLOAT.
          </button>
        {:else if floatEvent?.claimable}
          {#if floatEvent?.isOpen}
            {#if floatEvent?.requiresSecret}
              <label for="claimCode">
                Enter the claim code below (<i>case sensitive</i>).
                <input
                  type="text"
                  name="claimCode"
                  bind:value={claimCode}
                  placeholder="secret code"
                />
              </label>
            {/if}
            {#if floatEvent?.requiresSecret && claimCode === ""}
              <button class="secondary outline" disabled>
                You must enter a secret code.
              </button>
            {:else if $floatClaimingInProgress}
              <button aria-busy="true" disabled>Claiming FLOAT</button>
            {:else if $floatClaimedStatus.success}
              <a
                role="button"
                class="d-block"
                href="/account"
                style="display:block"
                >FLOAT claimed successfully!
              </a>
            {:else if !$floatClaimedStatus.success && $floatClaimedStatus.error}
              <button class="error" disabled>
                {$floatClaimedStatus.error}
              </button>
            {:else}
              <button
                disabled={$floatClaimingInProgress}
                on:click={() =>
                  claimFLOAT(floatEvent?.host, floatEvent?.id, claimCode)}
                >Claim this FLOAT
              </button>
            {/if}
          {:else if floatEvent?.capacity && floatEvent?.capacity <= floatEvent?.currentCapacity}
            <button class="secondary outline" disabled>
              This FLOAT is no longer available.<br /> All
              <span class="emphasis">
                {floatEvent?.currentCapacity}/{floatEvent?.capacity}
              </span> have been claimed.
            </button>
          {:else if floatEvent?.startTime > currentUnixTime}
            <button class="secondary outline" disabled>
              This FLOAT Event has not started yet.<br />
              Starting in
              <span class="emphasis">
                <Countdown unix={floatEvent?.startTime} />
              </span>
            </button>
          {:else if floatEvent?.endTime < currentUnixTime}
            <button class="secondary outline" disabled>
              This FLOAT is no longer available.<br />This event has ended.
            </button>
          {:else}
            <button class="secondary outline" disabled>
              This FLOAT is closed.<br />Unknown reason.
            </button>
          {/if}
        {:else}
          <button class="secondary outline" disabled>
            This FLOAT is not claimable.<br />The host has done this either to distribute it manually or halt claiming.
          </button>
        {/if}
        {#if $user?.addr == floatEvent?.host}
          <div class="toggle">
            <button
              class="outline"
              on:click={() => toggleClaimable(floatEvent?.id)}
            >
              {floatEvent?.claimable ? "Pause claiming" : "Resume claiming"}
            </button>
            <button
              class="outline"
              on:click={() => toggleTransferrable(floatEvent?.id)}
            >
              {floatEvent?.transferrable ? "Stop transfers" : "Allow transfers"}
            </button>
            <button
              class="outline red"
              disabled={floatEvent?.totalSupply !== 0}
              on:click={() => deleteEvent(floatEvent?.id)}
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
          <ClaimsTable address={floatEvent?.host} eventId={floatEvent?.id} />
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
