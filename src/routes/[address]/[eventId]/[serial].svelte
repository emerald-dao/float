<script>
  import { page } from "$app/stores";
  import Loading from "$lib/components/common/Loading.svelte";
  import Float from "$lib/components/Float.svelte";
  import { getEvent, getFLOAT, transferFLOAT, getCurrentHolder, deleteFLOAT } from "$lib/flow/actions.js";
  import Meta from '$lib/components/common/Meta.svelte';
  import { user } from "$lib/flow/stores";
  import { onMount } from "svelte";

  const floatEventCallback = async () => {
    return new Promise(async (resolve, reject) => {
      let event = await getEvent($page.params.address, $page.params.eventId);
      let holder = await getCurrentHolder($page.params.address, $page.params.eventId, $page.params.serial)
      let float = await getFLOAT(holder?.address, holder?.id);
      // console.log(event)
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

  onMount(() => {
    container.addEventListener('mousemove', (e) => {
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
  });

</script>

{#await data then data}
<Meta
  title="{data?.event.name} | FLOAT #{$page.params.eventId}"
  author={data?.event.host}
  description={data?.event.description}
  url={$page.url}
/>
{/await}

<div class="whole">
  <div class="wrap" bind:this={container}>
    <div class="float" bind:this={card}>
      {#await data then data}
        <div class="image" bind:this={image}>
          <img src={`https://ipfs.infura.io/ipfs/${data.event.image}`} alt="float">
        </div>
        <div class="info">
          <h1 bind:this={title}>{data.event.name}</h1>
          <p bind:this={createdBy}>
            <small>
              <span class="credit">Created by</span>
              <a href="/{data.event.host}" class="host">{data.event.host}</a>
            </small>
          </p>
          <code data-tooltip="Serial #" bind:this={serial}>#{data.float.serial}</code>
        </div>
      {/await}
    </div>
  </div>
</div>

{#await data then data}

  {#if $user?.addr == data?.float.owner}
    <article class="toggle">
      <header>
        {#if data?.float.owner}
          <h3>Owned by {data?.float.owner === $user.addr ? "you" : data?.float.owner}</h3>
          <small class="muted">Originally received by {data?.float.originalRecipient}</small>
        {:else}
          <h3>This FLOAT was deleted.</h3>
          <small class="muted">Original Recipient: Unknown</small>
        {/if}
      </header>
      <button class="outline red" on:click={() => deleteFLOAT(data?.float.id)}>
        Delete this FLOAT
      </button>
      <footer>
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
      </footer>
    </article>
  {/if}

{/await}

<style>
  .whole {
    position: relative;
    display: flex;
    justify-content: center;
    align-items: center;
    box-sizing: border-box;
    margin: 0;
    padding: 0;
    left: 0;
  }

  .wrap {
    /* Body Stuff */
    width: 50%;
    display: flex;
    justify-content: center;
    align-items: center;
    perspective: 1000px;
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

</style>
