<script context="module">
  export const prerender = true;

  import {
    claimFLOATv2,
    getEvent,
    resolveAddressObject,
  } from "$lib/flow/actions.js";

  export async function load({ url, params, stuff }) {
    let resolvedNameObject = await resolveAddressObject("0x99bd48c8036e2876");

    // TODO: change with actual FLOAT account and eventID
    const response = await getEvent(resolvedNameObject.address, 974907334);

    return {
      status: 200,
      props: {
        resolvedNameObject,
        eventData: response,
      },
      stuff: {
        title: "a16z CSS | Claim your unique a16z CSS participation NFT!",
        description: response?.description,
        author: response?.host,
        removeTitleSuffix: true,
        image: "https://pbs.twimg.com/media/FfXi7JDUcAAysE7.png",
      },
    };
  }
</script>

<script>
  import { page } from "$app/stores";
  import { user } from "$lib/flow/stores";
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
  import Socials from "$lib/components/common/Socials.svelte";

  let limitedVerifier;
  let flowTokenCost;
  let groups;

  export let resolvedNameObject;
  export let eventData;

  let resolvedHostName = getResolvedName(resolvedNameObject);

  const floatEventCallback = async () => {
    if (denylist.includes(resolvedNameObject.address)) {
      return null;
    }
    if (!eventData) {
      return null;
    }
    let hasClaimed = await hasClaimedEvent(
      resolvedNameObject.address,
      eventData.eventId,
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
            <h1>Thank you for visiting us at a16z CSS!</h1>
            <p>04/12/2023</p>
          </div>
        </header>
        <div class="grid">
          <div>
            {#if floatEvent?.hasClaimed}
              <div class="claimed-badge">✓ You claimed this FLOAT</div>
            {/if}

            {#if floatEvent.image}
              <img
                class="float-image"
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

            <Socials
              web="https://a16zcrypto.com/crypto-startup-school/"
              insta="a16z"
              twitter="a16z" />
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
              <strong><small class="muted">DESCRIPTION</small></strong
              ><br />This unique NFT was claimable on April 12th 2023 to
              commemorate joining us at the a16z CSS infrastructure exposition.
            </blockquote>

            <blockquote>
              <strong><small class="muted">STATS</small></strong><br />
              <p>
                <span class="emphasis"
                  >{parseInt(floatEvent?.totalSupply).toLocaleString()}</span> are
                minted.
              </p>
            </blockquote>
          </div>
        </div>
        <footer>
          {#if floatEvent?.hasClaimed}
            <button class="secondary outline" disabled
              >🎉 You already claimed this FLOAT! 🎉 <br /><small
                >Share your love of NFTs using #a16zCSS!</small
              ></button>
          {:else}
            <button
              class="primary"
              on:click={() =>
                claimFLOATv2(floatEvent.eventId, floatEvent.host, null)}
              >Claim this FLOAT</button>
          {/if}
        </footer>
      </article>
    {/if}
  {/await}

  <!-- <article>
    <header>
      <h1>About NFT Day</h1>
    </header>

    <p style="text-align:left">
      NFT Day is meant for everyone, an all-inclusive moment the entire Web3
      world can rally around. From creators and collectors, to developers and
      founders, NFT Day is a celebration of the entire ecosystem across every
      blockchain.
    </p>
    <p style="text-align:left">
      This September 20 marks the five-year anniversary of Dapper Labs CTO Dete
      Shirley publishing <a href="https://github.com/ethereum/eips/issues/721"
        >ERC-721</a
      >, which would go on to become the NFT standard. Since then, NFTs have
      become the lifeblood of communities, innovation, and blockchain adoption.
      NFT Day is a new officially recognized holiday.
    </p>
    <hr />

    <Socials
      web="https://internationalnftday.org"
      insta="officialnftday"
      twitter="OfficialNFTDay" />
    <footer>
      <strong>Pro Tip 👉 </strong> Collect your NFT Day FLOAT with
      <strong>Dapper</strong> and automatically be entered into a drawing to win
      NFT Day merchandise.
    </footer>
  </article> -->

  <article>
    <header>
      <h1>How to choose your wallet</h1>
    </header>
    <div class="wallet-container grid" style="text-align:left">
      <div>
        <h3><img src="dapper-logo.png" class="logo" /> Dapper</h3>
        <p>
          Dapper is the digital wallet that millions of people use to find, earn
          and own digital assets built on the Flow blockchain. Designed for ease
          of use, Dapper provides a fun and safe experience for exploring Web3.
        </p>
      </div>
      <div>
        <h3><img src="blocto-logo.jpg" class="logo" /> Blocto</h3>
        <p>
          Blocto, is an all-in-one cross-chain crypto wallet to manage your
          tokens, dApps, crypto assets, and NFTs. Blocto also has built-in token
          swapping functionality.
        </p>
      </div>
      <div>
        <h3><img src="lilico-logo.jpg" class="logo" /> Lilico</h3>
        <p>
          Lilico is the next-generation and non-custodial browser extension
          wallet built for NFTs on Flow. Lilico is simple and offers intuitive
          controls to secure your crypto assets.
        </p>
        <!-- <p>Lilico brings more fun to the web3 experience while letting you have full ownership of all your assets at all times.</p> -->
      </div>
    </div>
  </article>
</div>

<style>
  .logo {
    border-radius: 50%;
    width: 40px;
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
    width: 100%;
    margin-bottom: 20px;
    margin-top: 40px;
    border-radius: 20px;
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
    padding: 0px;
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
