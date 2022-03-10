<script>
  import { page } from "$app/stores";
  import {
    getFLOAT,
    transferFLOAT,
    getCurrentHolder,
    deleteFLOAT,
    resolveAddressObject,
  } from "$lib/flow/actions.js";
  import Meta from "$lib/components/common/Meta.svelte";
  import {
    floatDeletionInProgress,
    floatDeletionStatus,
    floatTransferInProgress,
    floatTransferStatus,
    user,
  } from "$lib/flow/stores";
  import { getResolvedName } from "$lib/flow/utils";
  import Loading from "$lib/components/common/Loading.svelte";
  import CopyBadge from "$lib/components/common/CopyBadge.svelte";

  let eventOwnerResolvedName;
  let eventOwnerObject;
  let owner;
  let floatOwner;
  let floatOriginalOwner;
  const floatCallback = async () => {
    eventOwnerObject = await resolveAddressObject($page.params.address);
    eventOwnerResolvedName = getResolvedName(eventOwnerObject);
    let holder = await getCurrentHolder(
      eventOwnerObject.address,
      $page.params.eventId,
      $page.params.serial
    );
    if (!holder) {
      return "deleted";
    } else {
      let float = await getFLOAT(holder.address, holder.id);
      owner = holder.address;
      let floatOwnerObject = await resolveAddressObject(owner);
      floatOwner = getResolvedName(floatOwnerObject);
      let floatOriginalOwnerObject = await resolveAddressObject(
        float.float.originalRecipient
      );
      floatOriginalOwner = getResolvedName(floatOriginalOwnerObject);
      return {
        ...float.float,
        totalSupply: float.totalSupply,
        transferrable: float.transferrable,
      };
    }
  };
  let recipientAddr = "";
  let data = floatCallback();

  // JS STUFF
  let card;
  let container;
  let title;
  let image;
  let createdBy;
  let serial;

  $: if ((card, container, title, image, createdBy, serial)) {
    // once dom elements are loaded, fire animate
    animate(container);
    // then delete animate as it would keep firing
    animate = () => {};
  }

  function animate(container) {
    container.addEventListener("mousemove", (e) => {
      let xAxis = (window.innerWidth / 2 - e.pageX) / 50;
      let yAxis = (window.innerHeight / 2 - e.pageY) / 50;
      card.style.transform = `rotateY(${xAxis}deg) rotateX(${yAxis}deg)`;
    });

    container.addEventListener("touchmove", (e) => {
      let xAxis = (window.innerWidth / 2 - e.pageX) / 50;
      let yAxis = (window.innerHeight / 2 - e.pageY) / 50;
      card.style.transform = `rotateY(${xAxis}deg) rotateX(${yAxis}deg)`;
    });

    container.addEventListener("mouseenter", (e) => {
      setTimeout(() => {
        card.style.transition = "none";
      }, 300);
      title.style.transform = "translateZ(150px)";
      image.style.transform = "translateZ(200px)";
      createdBy.style.transform = "translateZ(125px)";
      serial.style.transform = "translateZ(100px)";
    });

    container.addEventListener("mouseleave", (e) => {
      card.style.transition = "all 0.5s ease";
      card.style.transform = `rotateY(0deg) rotateX(0deg)`;
      title.style.transform = "translateZ(0px)";
      image.style.transform = "translateZ(0px)";
      createdBy.style.transform = "translateZ(0px)";
      serial.style.transform = "translateZ(0px)";
    });
  }
</script>

{#await data then data}
  <Meta
    title="{data.eventName} | FLOAT #{$page.params.eventId}"
    author={data.eventHost}
    description={data.description}
    url={$page.url} />
{/await}

{#await data}
  <Loading />
{:then data}
  {#if data == "deleted"}
    <article>
      This FLOAT has been deleted or it has not been minted yet.
    </article>
  {:else}
    <article class="toggle">
      <header>
        <h3>FLOAT #{data.id}</h3>
        <p style="margin-bottom: 10px;">
          Owned by {floatOwner} | Originally claimed by {floatOriginalOwner}
        </p>
        <div
        class="command-badge mono"
        data-tooltip="Paste into Discord to view FLOAT">
        <svg data-svg-carbon-icon="LogoDiscord24" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32" fill="currentColor" width="24" height="24" preserveAspectRatio="xMidYMid meet">
          <path d="M13.647,14.907a1.4482,1.4482,0,1,0,1.326,1.443A1.385,1.385,0,0,0,13.647,14.907Zm4.745,0a1.4482,1.4482,0,1,0,1.326,1.443A1.385,1.385,0,0,0,18.392,14.907Z"></path><path d="M24.71,4H7.29A2.6714,2.6714,0,0,0,4.625,6.678V24.254A2.6714,2.6714,0,0,0,7.29,26.932H22.032l-.689-2.405,1.664,1.547L24.58,27.53,27.375,30V6.678A2.6714,2.6714,0,0,0,24.71,4ZM19.692,20.978s-.468-.559-.858-1.053a4.1021,4.1021,0,0,0,2.353-1.547,7.4391,7.4391,0,0,1-1.495.767,8.5564,8.5564,0,0,1-1.885.559,9.1068,9.1068,0,0,1-3.367-.013,10.9127,10.9127,0,0,1-1.911-.559,7.6184,7.6184,0,0,1-.949-.442c-.039-.026-.078-.039-.117-.065a.18.18,0,0,1-.052-.039c-.234-.13-.364-.221-.364-.221a4.0432,4.0432,0,0,0,2.275,1.534c-.39.494-.871,1.079-.871,1.079a4.7134,4.7134,0,0,1-3.965-1.976,17.409,17.409,0,0,1,1.872-7.579,6.4285,6.4285,0,0,1,3.653-1.365l.13.156a8.77,8.77,0,0,0-3.419,1.703s.286-.156.767-.377a9.7625,9.7625,0,0,1,2.951-.819,1.2808,1.2808,0,0,1,.221-.026,11,11,0,0,1,2.626-.026A10.5971,10.5971,0,0,1,21.2,11.917a8.6518,8.6518,0,0,0-3.237-1.651l.182-.208a6.4285,6.4285,0,0,1,3.653,1.365,17.409,17.409,0,0,1,1.872,7.579A4.752,4.752,0,0,1,19.692,20.978Z"></path>
        </svg>
        <span class="command">/float {floatOwner} {data.id}</span>
      </div>
      <CopyBadge text={`/float address:${floatOwner} floatid:${data.id}`}>
        </CopyBadge>
      </header>

      <div class="whole">
        <a
          href="/{eventOwnerResolvedName}/{data.eventId}"
          class="wrap"
          bind:this={container}>
          <div class="float transition" bind:this={card}>
            <div class="image transition" bind:this={image}>
              <img
                src={`https://ipfs.infura.io/ipfs/${data.eventImage}`}
                alt="float" />
            </div>
            <div class="info">
              <h1 class="transition" bind:this={title}>{data.eventName}</h1>
              <p class="transition" bind:this={createdBy}>
                <small>
                  <span class="credit">Created by</span>
                  <a href="/{eventOwnerResolvedName}" class="host"
                    >{eventOwnerResolvedName}</a>
                </small>
              </p>
              <code
                class="transition"
                data-tooltip="Serial #"
                bind:this={serial}>#{data.serial}</code>
            </div>
          </div>
        </a>
      </div>

      <blockquote>
        <strong><small class="muted">DESCRIPTION</small></strong><br />
        {data.eventDescription}
      </blockquote>
      {#if $user?.addr == owner}
        {#if $floatDeletionInProgress}
          <button class="outline red" aria-busy="true" disabled
            >Deleting FLOAT</button>
        {:else if $floatDeletionStatus.success}
          <button class="outline red">FLOAT deleted successfully.</button>
        {:else if !$floatDeletionStatus.success && $floatDeletionStatus.error}
          <button class="outline red" disabled>
            {$floatDeletionStatus.error}
          </button>
        {:else}
          <button class="outline red" on:click={() => deleteFLOAT(data.id)}>
            Delete this FLOAT
          </button>
        {/if}
      {/if}
    </article>

    {#if $user?.addr == owner && data.transferrable}
      <article>
        <label for="recipientAddr">
          Copy the recipient's address below.
          <input
            type="text"
            name="recipientAddr"
            bind:value={recipientAddr}
            placeholder="0x00000000000" />
        </label>
        {#if $floatTransferInProgress}
          <button aria-busy="true" disabled>Transferring FLOAT</button>
        {:else if $floatTransferStatus.success}
          <button>FLOAT transferred successfully.</button>
        {:else if !$floatTransferStatus.success && $floatTransferStatus.error}
          <button disabled>
            {$floatTransferStatus.error}
          </button>
        {:else}
          <button on:click={transferFLOAT(data.id, recipientAddr)}>
            Transfer this FLOAT
          </button>
        {/if}
      </article>
    {/if}
  {/if}
{/await}

<style>
  .copy {
    background: var(--primary);
    color: var(--primary-inverse);
    cursor: pointer;
  }

  .whole {
    position: relative;
    display: flex;
    width: 100%;
    height: 100%;
    justify-content: center;
    align-items: center;
    box-sizing: border-box;
    margin: 0;
    padding: 0;
    left: 0;
    z-index: 10000;
  }

  .wrap {
    /* Body Stuff */
    width: 50%;
    display: flex;
    position: relatve;
    justify-content: center;
    align-items: center;
    perspective: 1000px;
    text-decoration: none;
  }

  .float {
    transform-style: preserve-3d;
    width: 20rem;
    min-height: 50vh;
    border-radius: 30px;
    padding: 1rem 1rem;
    padding-bottom: 2rem;
    box-shadow: 0 20px 20px rgb(0, 0, 0, 0.2), 0 0px 50px rgb(0, 0, 0, 0.2);
    background-color: var(--card-background-color);
  }

  .image {
    min-height: 35vh;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .image img {
    max-width: 200px;
    max-height: 200px;
  }

  .info {
    text-align: center;
    transform-style: preserve-3d;
  }

  .info h1 {
    font-size: 1.5rem;
  }

  .credit {
    margin-top: 20px;
    display: block;
  }

  .host {
    font-family: monospace;
  }

  article {
    text-align: center;
    align-items: center;
  }

  .muted {
    font-size: 0.7rem;
    opacity: 0.7;
  }
  blockquote {
    text-align: left;
  }

  .transition {
    transition-property: transform;
    transition-duration: 1s;
  }

  .command-badge {
    display:inline-flex;
    font-size:0.7rem;
    vertical-align: middle;
    justify-items: center;
    align-items:center;
    border: 1px solid var(--color);
    border-radius:5px;
    padding: 3px 8px;
  }

  .command {
    font-family:monospace;
    margin-left: 8px;
  }
</style>
