<script>
  import { page } from "$app/stores";
  import {
    user,
    floatDistributingInProgress,
    floatDistributingStatus,
    toggleClaimingInProgress,
    toggleTransferringInProgress,
  } from "$lib/flow/stores";
  import { PAGE_TITLE_EXTENSION } from "$lib/constants";
  import {
    getEvent,
    toggleClaimable,
    toggleTransferrable,
    deleteEvent,
    hasClaimedEvent,
    distributeDirectly,
    isSharedWithUser,
    addEventToGroup,
    getGroups,
removeEventFromGroup,
  } from "$lib/flow/actions.js";

  import IntersectionObserver from "svelte-intersection-observer";

  import Loading from "$lib/components/common/Loading.svelte";
  import Float from "$lib/components/Float.svelte";
  import Meta from "$lib/components/common/Meta.svelte";

  import ClaimsTable from "$lib/components/common/table/ClaimsTable.svelte";
  import ClaimButton from "$lib/components/ClaimButton.svelte";

  let claimsTableInView;
  let limitedVerifier;

  let groups;
  let groupsWeCanAddTo;
  const floatEventCallback = async () => {
    let eventData = await getEvent($page.params.address, $page.params.eventId);
    let hasClaimed = await hasClaimedEvent(
      $page.params.address,
      $page.params.eventId,
      $user.addr
    );
    let data = { ...eventData, hasClaimed };
    limitedVerifier =
      data.verifiers["A.0afe396ebc8eee65.FLOATVerifiers.Limited"];
    console.log(data);

    groups = await getGroups($page.params.address);
    groupsWeCanAddTo = Object.keys(groups).filter(groupName => !data.groups.includes(groupName));
    return data;
  };

  let floatEvent = floatEventCallback();
  let canMintForMe = isSharedWithUser($page.params.address, $user?.addr);

  let recipientAddr = "";
  let groupName = "";
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
      url={$page.url} />

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
            ).toLocaleString()}</small>
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
          list={false} />
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
          individual={false} />
      {/if}

      <blockquote>
        <strong><small class="muted">DESCRIPTION</small></strong
        ><br />{floatEvent?.description}
      </blockquote>

      {#if floatEvent?.groups.length > 0}
        <blockquote>
          <strong><small class="muted">GROUPS</small></strong>
          <br />
          {#each floatEvent?.groups as group}
            <a href="/{$page.params.address}/group/{group}"><div class="group-badge">{group}</div></a>
          {/each}
        </blockquote>
      {/if}

      <p>
        <span class="emphasis">{floatEvent?.totalSupply}</span> have been minted.
      </p>

      {#if limitedVerifier && limitedVerifier[0]}
        <p>
          Only <span class="emphasis">{limitedVerifier[0].capacity}</span> will ever
          exist.
        </p>
      {/if}
      <footer>
        <ClaimButton {floatEvent} hasClaimed={floatEvent?.hasClaimed} />
      </footer>
    </article>

    {#await canMintForMe then canMintForMe}
      {#if $user?.addr == floatEvent?.host || canMintForMe}
        <article>
          <h1>Admin Dashboard</h1>
          <div class="toggle">
            <button
              class="outline"
              disabled={$toggleClaimingInProgress}
              aria-busy={$toggleClaimingInProgress}
              on:click={() =>
                toggleClaimable($page.params.address, floatEvent?.eventId)}>
              {floatEvent?.claimable ? "Pause claiming" : "Resume claiming"}
            </button>
            <button
              class="outline"
              disabled={$toggleTransferringInProgress}
              aria-busy={$toggleTransferringInProgress}
              on:click={() =>
                toggleTransferrable($page.params.address, floatEvent?.eventId)}>
              {floatEvent?.transferrable ? "Stop transfers" : "Allow transfers"}
            </button>
            <button
              class="outline red"
              disabled={floatEvent?.totalSupply !== 0}
              on:click={() =>
                deleteEvent($page.params.address, floatEvent?.eventId)}>
              Delete this event
            </button>
          </div>

          <div class="input-group">
            <h4>Award Manually</h4>
            <div class="input-button-group">
              <input type="text" id="address" name="address" placeholder="0x00000000000" bind:value={recipientAddr}>
              {#if $floatDistributingInProgress}
                <button aria-busy="true" disabled>
                  Award
                </button>
              {:else if $floatDistributingStatus.success}
                <a
                  role="button"
                  class="d-block"
                  href="/{recipientAddr}"
                  style="display:block">Awarded</a>
              {:else if !$floatDistributingStatus.success && $floatDistributingStatus.error}
                <button class="error" disabled>
                  {$floatDistributingStatus.error}
                </button>
              {:else}
                <button
                  disabled={$floatDistributingInProgress}
                  on:click={() =>
                    distributeDirectly(
                      $page.params.address,
                      floatEvent?.eventId,
                      recipientAddr
                    )}
                  >Award
                </button>
              {/if}
            </div>
            <small>Paste in a Flow address.</small>
          </div>

          {#if groupsWeCanAddTo.length > 0}
            <div class="input-group">
              <h4>Add to Group</h4>
              <div class="input-button-group">
                <select bind:value={groupName} id="addToGroup" required>
                  {#each groupsWeCanAddTo as group}
                    <option value={group}>{group}</option>
                  {/each}
                </select>
                <button
                  on:click={() =>
                    addEventToGroup(
                      $page.params.address,
                      groupName,
                      floatEvent?.eventId
                    )}>Add</button>
              </div>
              <small>Add to a pre-existing Group.</small>
            </div>
          {/if}

          {#if floatEvent.groups.length > 0}
          <div class="input-group">
            <h4>Remove from a Group</h4>
            <div class="input-button-group">
              <select bind:value={groupName} id="removeFromGroup" required>
                {#each floatEvent.groups as group}
                  <option value={group}>{group}</option>
                {/each}
              </select>
              <button
                on:click={() =>
                  removeEventFromGroup(
                    $page.params.address,
                    groupName,
                    floatEvent?.eventId
                  )}>Remove</button>
            </div>
            <small>Add to a pre-existing Group.</small>
          </div>
          {/if}
        </article>
      {/if}
    {/await}

    <article>
      <header>
        <h3>Owned by</h3>
      </header>
      <IntersectionObserver once element={claimsTableInView} let:intersecting>
        <div bind:this={claimsTableInView}>
          {#if intersecting}
            <ClaimsTable
              address={floatEvent?.host}
              eventId={floatEvent?.eventId} />
          {/if}
        </div>
      </IntersectionObserver>
    </article>
  {/await}
</div>

<style>
  h4 {
    margin: 0px;
    margin-bottom: 10px;
  }
  .input-group {
    text-align: left;
    margin-top: 30px;
  }

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
    width: 250px;
    margin: 0 auto;
    padding: 0.3rem 0.5rem;
    border: 1px solid var(--green);
    border-radius: 100px;
    color: var(--green);
    font-size: 0.7rem;
  }

  .group-badge {
    display: inline-block;
    margin-right: 15px;
    margin-top: 5px;
    padding: 0.3rem 0.75rem;
    border: 1px solid var(--primary);
    border-radius: 100px;
    color: var(--primary);
    font-size: 0.7rem;
  }

  .claims {
    text-align: left;
  }

  .admin {
    text-align: left;
  }
</style>
