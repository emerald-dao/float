<script>
  import { page } from "$app/stores";
  import { getEvent, getFLOAT, transferFLOAT, getCurrentHolder, deleteFLOAT } from "$lib/flow/actions.js";
  import Meta from '$lib/components/common/Meta.svelte';
  import { user } from "$lib/flow/stores";
import { convertAddress } from "$lib/flow/utils";
  
  const floatEventCallback = async () => {
    return new Promise(async (resolve, reject) => {
      let event = await getEvent($page.params.address, $page.params.eventId);
      let holder = await getCurrentHolder($page.params.address, $page.params.eventId, $page.params.serial)
      let float = await getFLOAT(holder?.address, holder?.id);
      resolve({event, float});
    })
  }
  let recipientAddr = "";
  let data = floatEventCallback();
  
  // JS STUFF
  let card;
  let container;
  let title;
  let image;
  let createdBy;
  let serial;
  
  $: if(card, container, title, image, createdBy, serial) {
    // once dom elements are loaded, fire animate
    animate(container)
    // then delete animate as it would keep firing
    animate = () => {}
  }
  
  
  function animate(container) {
    container.addEventListener('mousemove', (e) => {
      let xAxis = (window.innerWidth / 2 - e.pageX) / 25;
      let yAxis = (window.innerHeight / 2 - e.pageY) / 25;
      card.style.transform = `rotateY(${xAxis}deg) rotateX(${yAxis}deg)`;
    });
    
    container.addEventListener('touchmove', (e) => {
      let xAxis = (window.innerWidth / 2 - e.pageX) / 25;
      let yAxis = (window.innerHeight / 2 - e.pageY) / 25;
      card.style.transform = `rotateY(${xAxis}deg) rotateX(${yAxis}deg)`;
    });
    
    container.addEventListener('mouseenter', (e) => {
      setTimeout(() => {
        card.style.transition = 'none';
      }, 300);
      title.style.transform = 'translateZ(150px)';
      image.style.transform = 'translateZ(200px)';
      createdBy.style.transform = 'translateZ(125px)';
      serial.style.transform = 'translateZ(100px)';
    });
    
    container.addEventListener('mouseleave', (e) => {
      card.style.transition = 'all 0.5s ease';
      card.style.transform = `rotateY(0deg) rotateX(0deg)`;
      title.style.transform = 'translateZ(0px)';
      image.style.transform = 'translateZ(0px)';
      createdBy.style.transform = 'translateZ(0px)';
      serial.style.transform = 'translateZ(0px)';
    });
    
  }
</script>

{#await data then data}
<Meta
title="{data?.event.name} | FLOAT #{$page.params.eventId}"
author={data?.event.host}
description={data?.event.description}
url={$page.url}
/>
{/await}

{#await data then data}
<article class="toggle">
  <header>
    {#if data?.float.owner}
    <h3>Owned by {convertAddress(data?.float.owner)}</h3>
    <small class="muted">Originally claimed by {convertAddress(data?.float.originalRecipient)}</small>
    {:else}
    <h3>This FLOAT was deleted.</h3>
    <small class="muted">Original Recipient: Unknown</small>
    {/if}
  </header>
  
  <div class="whole">
    <a href="/{data.event.host}/{data.event.eventId}" class="wrap" bind:this={container}>
      <div class="float transition" bind:this={card}>
        <div class="image transition" bind:this={image}>
          <img src={`https://ipfs.infura.io/ipfs/${data.event.image}`} alt="float">
        </div>
        <div class="info">
          <h1 class="transition" bind:this={title}>{data.event.name}</h1>
          <p class="transition" bind:this={createdBy}>
            <small>
              <span class="credit">Created by</span>
              <a href="/{data.event.host}" class="host">{data.event.host}</a>
            </small>
          </p>
          <code class="transition" data-tooltip="Serial #" bind:this={serial}>#{data.float.serial}</code>
        </div>
      </div>
    </a>
  </div>
  
  <blockquote>
    <strong><small class="muted">DESCRIPTION</small></strong><br/>
    {data?.event.description}
  </blockquote>
  {#if $user?.addr == data?.float.owner}
  <button class="outline red" on:click={() => deleteFLOAT(data?.float.id)}>
    Delete this FLOAT
  </button>
  {/if}
</article>

{#if $user?.addr == data?.float.owner}
<article>
  <label for="recipientAddr">
    Copy the recipient's address below.
    <input
    type="text"
    name="recipientAddr"
    bind:value={recipientAddr}
    placeholder="0x00000000000"
    />
  </label>
  <button on:click={transferFLOAT(data?.float.id, recipientAddr)}>Transfer this FLOAT</button>
</article>
{/if}
{/await}

<style>
  .whole {
    position: relative;
    display: flex;
    width: 100%;
    height:100%;
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
    position:relatve;
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
    padding: 1rem 5rem;
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
    width: 20rem;
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
  
</style>
