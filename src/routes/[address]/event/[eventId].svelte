<script context="module">
  export const prerender = true;

  import { getEvent, resolveAddressObject } from "$lib/flow/actions.js";

  export async function load({ url, params, stuff }) {
    // console.log('CONSOLE', params);
    let eventId = params.eventId;
    let addr = params.address;

    let resolvedNameObject = await resolveAddressObject(addr);

    // console.log('resolved', resolvedNameObject.address)

    const response = await getEvent(resolvedNameObject.address, eventId);

    return {
      status: 200,
      props: {
        resolvedNameObject,
        eventData: response,
      },
      stuff: {
        title: response?.name + " | Claim this FLOAT by " + addr,
        description: response?.description,
        author: response?.host,
        removeTitleSuffix: true,
        //image: `https://nftstorage.link/ipfs/${response.image}`
        //image: `https://nftstorage.link/ipfs/${response.image}`
      },
    };
  }
</script>

<script>
  import { t } from "svelte-i18n";
  import { page } from "$app/stores";
  import {
    user,
    floatDistributingInProgress,
    floatDistributingStatus,
    toggleClaimingInProgress,
    toggleTransferringInProgress,
    addEventToGroupInProgress,
    addEventToGroupStatus,
    removeEventFromGroupInProgress,
    removeEventFromGroupStatus,
    deleteEventInProgress,
    deleteEventStatus,
    floatDistributingManyStatus,
    floatDistributingManyInProgress,
  } from "$lib/flow/stores";
  import { denylist } from "$lib/constants";
  import {
    toggleClaimable,
    toggleTransferrable,
    deleteEvent,
    hasClaimedEvent,
    distributeDirectly,
    isSharedWithUser,
    addEventToGroup,
    getGroups,
    removeEventFromGroup,
    distributeDirectlyMany,
    getCurrentHolder,
    getFlowTokenBalance,
    getClaimedInEvent,
  } from "$lib/flow/actions.js";
  import IntersectionObserver from "svelte-intersection-observer";
  import Loading from "$lib/components/common/Loading.svelte";
  import Float from "$lib/components/Float.svelte";
  import ClaimsTable from "$lib/components/common/table/ClaimsTable.svelte";
  import ClaimButton from "$lib/components/ClaimButton.svelte";
  import { getResolvedName } from "$lib/flow/utils";
  import QrCode from "$lib/components/common/QRCode.svelte";
  import { authenticate } from "$lib/flow/actions";
  import { flowTokenIdentifier, verifiersIdentifier } from "$lib/flow/config";
  let claimsTableInView;
  let limitedVerifier;
  let flowTokenCost;
  let minimumBalanceVerifier;
  let challengeCertificateVerifier;
  let confirmed = false;
  let groups;
  let groupsWeCanAddTo;
  let isSharedWithMe;

  export let resolvedNameObject;
  export let eventData;

  const floatEventCallback = async () => {
    if (denylist.includes(resolvedNameObject.address)) {
      return null;
    }
    if (!eventData) {
      return null;
    }
    let hasClaimed = await hasClaimedEvent(
      resolvedNameObject.address,
      $page.params.eventId,
      $user.addr
    );

    let currentOwner;
    if (hasClaimed) {
      currentOwner = await getCurrentHolder(
        resolvedNameObject.address,
        $page.params.eventId,
        hasClaimed.serial
      );
    }
    let data = { ...eventData, hasClaimed, currentOwner };
    limitedVerifier =
      data.verifiers[`${verifiersIdentifier}.FLOATVerifiers.Limited`];
    minimumBalanceVerifier =
      data.verifiers[`${verifiersIdentifier}.FLOATVerifiers.MinimumBalance`];
    challengeCertificateVerifier =
      data.verifiers[
        Object.keys(data.verifiers ?? {}).find((key) =>
          key.endsWith("FLOATVerifiers.ChallengeAchievementPoint")
        )
      ];
    let prices = data.extraMetadata["prices"];
    if (prices) {
      flowTokenCost = prices[`${flowTokenIdentifier}.FlowToken.Vault`]?.price;
    }
    groups = await getGroups(resolvedNameObject.address);
    groupsWeCanAddTo = Object.keys(groups).filter(
      (groupName) => !data.groups.includes(groupName)
    );
    isSharedWithMe = isSharedWithUser(resolvedNameObject.address, $user?.addr);
    return data;
  };
  let floatEvent = floatEventCallback();
  let recipientAddr = "";
  let groupName = "";
  let listOfAddresses;
  const uploadList = (e) => {
    const file = e.target.files[0];
    if (file.type === "text/csv") {
      var fr = new FileReader();
      fr.onload = (e) => {
        let stuff = e.target.result;
        listOfAddresses = stuff.split(",");
      };
      fr.readAsText(file);
    } else {
      listOfAddresses = "error";
    }
  };

  const downloadList = async () => {
    const listOfClaimers = await getClaimedInEvent(
      resolvedNameObject.address,
      $page.params.eventId
    );
    const arrayOfClaimers = Object.keys(listOfClaimers);
    let csvContent = "data:text/csv;charset=utf-8,";
    for (let i = 0; i < arrayOfClaimers.length; i++) {
      if (i == arrayOfClaimers.length - 1) {
        csvContent += arrayOfClaimers[i];
      } else {
        csvContent += arrayOfClaimers[i] + ",";
      }
    }
    var encodedUri = encodeURI(csvContent);
    window.open(encodedUri);
  };
</script>

<div class="container">
  {#await floatEvent}
    <Loading />
  {:then floatEvent}
    {#if !floatEvent}
      <article>
        <p>This event is deleted or the acount is denylisted.</p>
      </article>
    {:else}
      <article>
        <header>
          <a href={floatEvent?.url} target="_blank">
            <h1>{floatEvent?.name}</h1>
          </a>
          <QrCode data={window.location.href} image={floatEvent?.image} />
          <p>FLOAT Event #{$page.params.eventId}</p>
          <p>
            <small class="muted">
              Created on {new Date(
                floatEvent?.dateCreated * 1000
              ).toLocaleString()}
            </small>
          </p>
        </header>
        {#if floatEvent?.hasClaimed}
          <div class="claimed-badge">✓ You claimed this FLOAT</div>
          <Float
            float={{
              id: floatEvent.hasClaimed.id,
              owner: floatEvent.currentOwner?.address,
              eventHost: floatEvent.host,
              eventImage: floatEvent.image,
              eventName: floatEvent.name,
              totalSupply: floatEvent.totalSupply,
              serial: floatEvent.hasClaimed.serial,
            }}
            claimed={true} />
        {:else}
          <Float
            float={{
              eventHost: floatEvent.host,
              eventImage: floatEvent.image,
              eventName: floatEvent.name,
              totalSupply: floatEvent.totalSupply,
            }} />
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
              <a href="/{getResolvedName(resolvedNameObject)}/group/{group}"
                ><div class="group-badge">{group}</div></a>
            {/each}
          </blockquote>
        {/if}
        <blockquote>
          <strong><small class="muted">COST</small></strong>
          <br />
          {#if flowTokenCost}
            {#await getFlowTokenBalance($user?.addr) then balance}
              This FLOAT costs
              <span class="emphasis">
                {parseFloat(flowTokenCost).toFixed(2)}
              </span>
              $FLOW to claim.
              {#if !floatEvent?.hasClaimed && (parseFloat(balance) - parseFloat(flowTokenCost)).toFixed(2) >= 0}
                You have
                <span class="emphasis"> {parseFloat(balance).toFixed(2)} </span>
                $FLOW. After purchasing, your final balance will be
                <span class="emphasis">
                  {(parseFloat(balance) - parseFloat(flowTokenCost)).toFixed(2)}
                </span> $FLOW.
              {:else if !floatEvent?.hasClaimed && (parseFloat(balance) - parseFloat(flowTokenCost)).toFixed(2) < 0}
                You cannot afford this FLOAT.
              {/if}
            {/await}
          {:else}
            Free
          {/if}
        </blockquote>
        {#if minimumBalanceVerifier && minimumBalanceVerifier[0]}
          <blockquote>
            <strong><small class="muted">MINIMUM BALANCE</small></strong>
            This FLOAT requires a minimum balance of
            <span class="emphasis">
              {" " +
                parseFloat(minimumBalanceVerifier[0].amount).toFixed(2) +
                " "}
            </span>
            $FLOW to claim. This amount will <strong>NOT</strong> be withdrawn from
            your account.
          </blockquote>
        {/if}
        {#if challengeCertificateVerifier && challengeCertificateVerifier[0]}
          <blockquote>
            <strong>
              <small class="muted">
                {$t("events.detail.section-info-cert-label")}
                <a
                  href={`/${challengeCertificateVerifier[0].challengeIdentifier.host}/challenge/${challengeCertificateVerifier[0].challengeIdentifier.id}`}
                  target="_blank">
                  {$t("events.detail.section-info-link")}
                </a>
              </small>
            </strong>
            <br />
            {@html $t("events.detail.section-info-cert-desc", {
              values: {
                n: challengeCertificateVerifier[0].challengeThresholdPoints,
              },
            })}
          </blockquote>
        {/if}
        <p>
          <span class="emphasis">
            {parseInt(floatEvent?.totalSupply).toLocaleString()}
          </span> have been minted.
        </p>
        {#if limitedVerifier && limitedVerifier[0]}
          <p>
            Only <span class="emphasis">{limitedVerifier[0].capacity}</span> will
            ever exist.
          </p>
        {/if}
        <footer>
          {#if $user?.loggedIn}
            <ClaimButton
              {flowTokenCost}
              {floatEvent}
              hasClaimed={floatEvent?.hasClaimed} />
          {:else}
            <button id="connect" on:click={authenticate}>Connect Wallet</button>
          {/if}
        </footer>
      </article>
      {#await isSharedWithMe then isSharedWithMe}
        {#if isSharedWithMe}
          <article>
            <h1>Admin Dashboard</h1>
            <div class="toggle">
              <button
                class="outline"
                disabled={$toggleClaimingInProgress}
                aria-busy={$toggleClaimingInProgress}
                on:click={() =>
                  toggleClaimable(
                    resolvedNameObject.address,
                    floatEvent?.eventId
                  )}>
                {floatEvent?.claimable ? "Pause claiming" : "Resume claiming"}
              </button>
              <button
                class="outline"
                disabled={$toggleTransferringInProgress}
                aria-busy={$toggleTransferringInProgress}
                on:click={() =>
                  toggleTransferrable(
                    resolvedNameObject.address,
                    floatEvent?.eventId
                  )}>
                {floatEvent?.transferrable
                  ? "Stop transfers"
                  : "Allow transfers"}
              </button>
              {#if $deleteEventInProgress}
                <button class="outline red" aria-busy="true" disabled>
                  Deleting...
                </button>
              {:else if $deleteEventStatus.success}
                <button class="outline red" disabled>Deleted</button>
              {:else if !$deleteEventStatus.success && $deleteEventStatus.error}
                <button class="error" disabled> Error </button>
              {:else}
                <button
                  class="outline red"
                  on:click={() =>
                    deleteEvent(
                      resolvedNameObject.address,
                      floatEvent?.eventId
                    )}>
                  Delete this event
                </button>
              {/if}
            </div>
            <div class="input-group">
              <h4>Award Manually</h4>
              <div class="input-button-group">
                <input
                  type="text"
                  id="address"
                  name="address"
                  placeholder="0x00000000000"
                  bind:value={recipientAddr} />
                {#if $floatDistributingInProgress}
                  <button aria-busy="true" disabled> Award </button>
                {:else if !$floatDistributingStatus.success && $floatDistributingStatus.error}
                  <button class="error" disabled> Error </button>
                {:else}
                  <button
                    disabled={$floatDistributingInProgress}
                    on:click={() =>
                      distributeDirectly(
                        resolvedNameObject.address,
                        floatEvent?.eventId,
                        recipientAddr
                      )}
                    >Award
                  </button>
                {/if}
              </div>
              <small>Paste in a Flow address.</small>
            </div>
            <div class="input-group">
              <h4>Award Manually to Many</h4>
              <div class="input-button-group">
                <input
                  type="file"
                  id="list"
                  name="list"
                  placeholder="0x00000000000"
                  on:change={uploadList} />
                {#if $floatDistributingManyInProgress}
                  <button aria-busy="true" disabled> Award </button>
                {:else if !$floatDistributingManyStatus.success && $floatDistributingManyStatus.error}
                  <button class="error" disabled> Error </button>
                {:else}
                  <button
                    disabled={$floatDistributingManyInProgress ||
                      listOfAddresses === "error"}
                    on:click={() =>
                      distributeDirectlyMany(
                        resolvedNameObject.address,
                        floatEvent?.eventId,
                        listOfAddresses
                      )}
                    >Award
                  </button>
                {/if}
              </div>
              {#if listOfAddresses && listOfAddresses !== "error"}
                <small>Minting to: {listOfAddresses.toString()}</small>
              {:else if listOfAddresses === "error"}
                <small class="red">
                  This file is not supported. Please upload a .csv file.
                </small>
              {:else}
                <small>
                  Upload a .csv file <a href="/example.csv" download>
                    (here is an example)
                  </a> of addresses.
                </small>
                <br />
                <small>
                  NOTE: 1) FLOATs will only be given to people who have set up
                  their collection already. 2) You can only distribute a maximum
                  of 200 FLOATs at a time.
                </small>
              {/if}
            </div>
            {#if groupsWeCanAddTo.length > 0}
              <div class="input-group">
                <h4>Add Event to Group</h4>
                <div class="input-button-group">
                  <select bind:value={groupName} id="addToGroup" required>
                    {#each groupsWeCanAddTo as group}
                      <option value={group}>{group}</option>
                    {/each}
                  </select>
                  {#if $addEventToGroupInProgress}
                    <button aria-busy="true" disabled>Adding</button>
                  {:else if !$addEventToGroupStatus.success && $addEventToGroupStatus.error}
                    <button class="error" disabled>
                      {$addEventToGroupStatus.error}
                    </button>
                  {:else}
                    <button
                      on:click={() =>
                        addEventToGroup(
                          resolvedNameObject.address,
                          groupName,
                          floatEvent?.eventId
                        )}>
                      Add
                    </button>
                  {/if}
                </div>
                <small>Add to a pre-existing Group.</small>
              </div>
            {/if}
            {#if floatEvent.groups.length > 0}
              <div class="input-group">
                <h4>Remove Event from Group</h4>
                <div class="input-button-group">
                  <select bind:value={groupName} id="removeFromGroup" required>
                    {#each floatEvent.groups as group}
                      <option value={group}>{group}</option>
                    {/each}
                  </select>
                  {#if $removeEventFromGroupInProgress}
                    <button aria-busy="true" disabled>Removing</button>
                  {:else if $removeEventFromGroupStatus.success}
                    <button disabled>Removed</button>
                  {:else if !$removeEventFromGroupStatus.success && $removeEventFromGroupStatus.error}
                    <button class="error" disabled>
                      {$removeEventFromGroupStatus.error}
                    </button>
                  {:else}
                    <button
                      on:click={() =>
                        removeEventFromGroup(
                          resolvedNameObject.address,
                          groupName,
                          floatEvent?.eventId
                        )}>Remove</button>
                  {/if}
                </div>
                <small>Remove from a Group.</small>
              </div>
            {/if}

            <button id="download" on:click={downloadList}>
              Download list of claimers
            </button>
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
                eventId={floatEvent?.eventId}
                totalClaimed={floatEvent?.totalSupply} />
            {/if}
          </div>
        </IntersectionObserver>
      </article>
    {/if}
  {/await}
</div>

<style>
  #download {
    margin-top: 40px;
  }
  #connect {
    background: var(--contrast);
    border: 0;
  }
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
  /* .claims {
    text-align: left;
  }
  .admin {
    text-align: left;
  } */
</style>
