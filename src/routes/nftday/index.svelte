<script context="module">
  export const prerender = true;

  import { getEvent, resolveAddressObject } from "$lib/flow/actions.js";

  export async function load({ url, params, stuff }) {

    let resolvedNameObject = await resolveAddressObject("0x11ca36743554b4b0");

    // TODO: change with actual FLOAT account and eventID
    const response = await getEvent(resolvedNameObject.address, 482472737);

    return {
      status: 200,
      props: {
        resolvedNameObject,
        eventData: response,
      },
      stuff: {
        title: "#NFTDay | Claim your unique NFT Day participation NFT!",
        description: response?.description,
        author: response?.host,
        removeTitleSuffix : true,
        image: "https://floats.city/nftday-logo.png"
        //image: `https://nftstorage.link/ipfs/${response.image}`
        //image: `https://nftstorage.link/ipfs/${response.image}`
      },
    };
  }
</script>

<script>
  import { page } from "$app/stores";
  import {
    user
  } from "$lib/flow/stores";
  import { denylist } from "$lib/constants";
  import {
    hasClaimedEvent,
    getGroups,
    getCurrentHolder,
  } from "$lib/flow/actions.js";
  import ConnectWallet from "$lib/components/ConnectWallet.svelte";
  import Loading from "$lib/components/common/Loading.svelte";
  import ClaimButton from "$lib/components/ClaimButton.svelte";
  import { getResolvedName } from "$lib/flow/utils";
  import { authenticate } from "$lib/flow/actions";

  let limitedVerifier;
  let flowTokenCost;
  let groups;

  export let resolvedNameObject;
  export let eventData;

  let resolvedHostName = getResolvedName(resolvedNameObject)

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

    groups = await getGroups(resolvedNameObject.address);

    return data;
  };
  let floatEvent = floatEventCallback();

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
          <div class="hero">
            <h1>Let's celebrate #NFTDay!</h1>
            <p>Claim your unique NFT and get special perks.</p>
          </div>
        </header>
        <div class="grid">
          <div>
            {#if floatEvent?.hasClaimed}
              <div class="claimed-badge">✓ You claimed this FLOAT</div>
            {/if}

            {#if floatEvent.image}
              <img class="float-image"
                src="https://nftstorage.link/ipfs/{floatEvent.image}"
                alt="{floatEvent.name} Image" />
            {/if}
            <p>
              <small class>
                <span class="credit">Created by</span>
                <a href="/{resolvedHostName}" class="host"
                  >{resolvedHostName}</a>
              </small>
            </p>
          </div>
          <div>
            {#if floatEvent?.groups.length > 0}
              <blockquote>
                <strong><small class="muted">GROUPS</small></strong>
                <br />
                {#each floatEvent?.groups as group}
                  <a href="/{resolvedHostName}/group/{group}"
                    ><div class="group-badge">{group}</div></a>
                {/each}
              </blockquote>
            {/if}
            <blockquote>
              <strong><small class="muted">COST</small></strong>
              Free
            </blockquote>

            <blockquote>
              <strong><small class="muted">DESCRIPTION</small></strong
              ><br />{floatEvent?.description}
            </blockquote>

            <blockquote>
              <strong><small class="muted">STATS</small></strong><br/>
              <p><span class="emphasis"
                >{parseInt(floatEvent?.totalSupply).toLocaleString()}</span> have been minted so far.</p>
            </blockquote>

            {#if limitedVerifier && limitedVerifier[0]}
              <p>
                Only <span class="emphasis">{limitedVerifier[0].capacity}</span> will
                ever exist.
              </p>
            {/if}
          </div>
        </div>
        <footer>
          {#if $user?.loggedIn}
            <ClaimButton
              {flowTokenCost}
              {floatEvent}
              hasClaimed={floatEvent?.hasClaimed} />
          {:else}
            <button id="connect" on:click={authenticate}>Claim your NFT</button>
          {/if}
        </footer>
      </article>
    {/if}
  {/await}

  <article>
    <header>
      <h1>How to choose your wallet</h1>
    </header>
    <div class="wallet-container" style="text-align:left">
      <div>
        <h2><img src="dapper-logo.png" class="logo"/> Dapper</h2>
        <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."</p>
      </div>

      <hr>

      <div>
        <h2><img src="blocto-logo.jpg" class="logo"/> Blocto</h2>
        <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."</p>
      </div>

      <hr>
      <div>
        <h2><img src="lilico-logo.jpg" class="logo"/> Lilico</h2>
        <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."</p>
      </div>
    </div>
<footer>
  <ConnectWallet />
</footer>
  </article>
</div>

<style>

  .logo {
    border-radius:50%;
    width: 80px;
    margin-right: 0.8rem;
  }
  .wallet-container h2 {
    margin-bottom: 1rem;
  }

  .wallet-container p {
    font-size: 0.8rem;
  }

  hr {
    margin: 1rem 0rem;
  }
  
  .float-image {
    max-width: 350px;
  }

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

  .host {
    font-family: monospace;
  }

  .credit {
    font-size: 0.7rem;
    display: block;
    line-height: 1;
  }

  p {
    margin-top: 10px;
    margin-bottom: 10px;
  }

  .nomargin {
    margin-right: 0px;
  }

  /* .claims {
    text-align: left;
  }
  .admin {
    text-align: left;
  } */
</style>
