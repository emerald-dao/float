<script>
  import { page } from '$app/stores';
  import { PAGE_TITLE_EXTENSION } from '$lib/constants'
  import { getFLOATEvent, claimFLOAT } from '$lib/flow/actions.js';
  import Loading from '$lib/components/common/Loading.svelte';
  import Float from '$lib/components/Float.svelte';
  import Countdown from '$lib/components/common/Countdown.svelte';
  
  let floatEvent = getFLOATEvent($page.params.address, $page.params.eventId);
  console.log(floatEvent);
  
  let claimCode = '';

  $: currentUnixTime = +new Date() / 1000;

</script>

<svelte:head>
<title>Claim {PAGE_TITLE_EXTENSION}</title>
</svelte:head>

<style>
  .container {
    text-align:center;
  }
  blockquote {
    text-align: left;
  }

  .secondary.outline {
    font-weight: 300;
  }

  .emphasis {
    font-weight: 400;
    color: var(--primary)
  }
</style>
<div class="container">
  
  
  
  
  {#await floatEvent}
  <Loading />
  {:then floatEvent}
  <article>
    <header>
      <h1>FLOAT #{$page.params.eventId}</h1>
    </header>
    <Float float={floatEvent} preview={true} />
    
    <blockquote>{floatEvent?.description}</blockquote>
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
      
      {#if floatEvent?.claimable}
        {#if floatEvent?.isOpen}
          {#if floatEvent?.requiresSecret}
          <label for="claimCode">Enter the claim code
            <input type="text" name="claimCode" bind:value={claimCode} placeholder="mySecretCode" />
          </label>
          {/if}
        <button on:click={() => claimFLOAT(floatEvent?.host, floatEvent?.id, claimCode)}>Claim this FLOAT</button>
        {:else if floatEvent?.capacity && floatEvent?.capacity <= floatEvent?.currentCapacity}
        <button class="secondary outline" disabled>This FLOAT is not claimable.<br/>This FLOAT is closed. All <span class="emphasis">{ floatEvent?.currentCapacity}/{floatEvent?.capacity}</span> have been claimed.</button>
        {:else if floatEvent?.startTime > currentUnixTime}
        <button class="secondary outline" disabled>
            This FLOAT is not claimable because it hasn't started yet.<br/>
            Starting in <span class="emphasis"><Countdown unix={floatEvent?.startTime} /></span>
        </button>
        {:else if floatEvent?.endTime < currentUnixTime}
        <button class="secondary outline" disabled>This FLOAT is not claimable.<br/>This event has ended.</button>
        {:else}
        <button class="secondary outline" disabled>This FLOAT is not claimable.<br/>Unknown reason.</button>
        {/if}
      {:else}
        <button class="secondary outline" disabled>This FLOAT is not claimable.<br/>The host opted to distribute it manually.</button>
      {/if}
    </footer>
  </article>
  {/await}

  
</div>

