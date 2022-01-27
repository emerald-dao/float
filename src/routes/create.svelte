<script>
  import { user } from "$lib/flow/stores";
  import { logIn } from '$lib/flow/actions';

  import { draftFloat } from '$lib/stores';
  
  let timezone = new Date().toLocaleTimeString('en-us',{timeZoneName:'short'}).split(' ')[2];
  

</script>
<svelte:head>
	<title>Account | Emerald FLOAT</title>
</svelte:head>

<div class="container">
  <article>
    
    <h1>Create a new FLOAT</h1>
  
    <div class="mt-2 mb-2">
    {#if !$user?.loggedIn}
    <button class="contrast small-button" on:click={logIn}>Connect Wallet</button>
    {:else}
    <label for="name">Event Name
      <input type="text" id="name" name="name" >
    </label>

    <label for="description">Event Description
      <textarea id="description" name="description"></textarea>
    </label>

<label for="image">Event Image
  <input type="file" id="image" name="image" accept="image/png, image/gif, image/jpeg" >
</label>

<!-- 

  Claimable: Yes vs No (No = host must distribute manually, similar to custom above; Yes = quantity, time and claimcode appears)
Quantity: UNLIMITED vs LIMITED (toggles FLOAT quantity limit input)
Time: UNLIMITED vs LIMITED (toggles start /end time inputs)
Requires Claim Code: Yes vs No (btw so are we going with hash or code after the event?) 
 -->
<h4>Configure FLOAT</h4>

<div class="grid">
  <button class:secondary={!$draftFloat.claimable} class="outline" on:click={() => $draftFloat.claimable = !$draftFloat.claimable}>Claimable</button>
  <button class:secondary={$draftFloat.claimable} class="outline" on:click={() => $draftFloat.claimable = !$draftFloat.claimable}>Not Claimable</button>
</div>

{#if $draftFloat.claimable}
<!-- QUANTITY -->
<div class="grid">
  <button class:secondary={$draftFloat.quantity} class="outline" on:click={() => $draftFloat.quantity = !$draftFloat.quantity}>Unlimited Quantity</button>
  <button class:secondary={!$draftFloat.quantity} class="outline" on:click={() => $draftFloat.quantity = !$draftFloat.quantity}>Limited Quantity</button>
</div>
{#if $draftFloat.quantity}
<label for="quantity">How many can be claimed? 
  <input type="number" name="quantity" bind:value={$draftFloat.quantity} min="1" placeholder="100" />
</label>
<hr/>
{/if}

<!-- TIME -->
<div class="grid">
  <button class:secondary={$draftFloat.timeBound} class="outline" on:click={() => $draftFloat.timeBound = !$draftFloat.timeBound}>No Time Limit</button>
  <button class:secondary={!$draftFloat.timeBound} class="outline" on:click={() => $draftFloat.timeBound = !$draftFloat.timeBound}>Time Limit</button>
</div>
{#if $draftFloat.timeBound}
<div class="grid">
  <!-- Date -->
  <label for="start">Start ({timezone})
    <input type="datetime-local" id="start" name="start" bind:value="{$draftFloat.startTime}">
  </label>
  
  <!-- Date -->
  <label for="start">End ({timezone})
    <input type="datetime-local" id="start" name="start" bind:value="{$draftFloat.endTime}">
  </label>
</div>
<hr/>
{/if}

<!-- TIME -->
<div class="grid">
  <button class:secondary={$draftFloat.claimCodeEnabled} class="outline" on:click={() => $draftFloat.claimCodeEnabled = !$draftFloat.claimCodeEnabled}>Anyone Can Claim</button>
  <button class:secondary={!$draftFloat.claimCodeEnabled} class="outline" on:click={() => $draftFloat.claimCodeEnabled = !$draftFloat.claimCodeEnabled}>Use Claim Code</button>
</div>
{#if $draftFloat.claimCodeEnabled}
<label for="claimCode">Enter a claim code
  <input type="text" name="claimCode" bind:value={$draftFloat.claimCode} placeholder="mySecretCode" />
</label>
<hr/>
{/if}

{:else}
<p>You will be responsible for awarding the FLOAT to specific accounts.</p>
{/if}

  <button>Create FLOAT</button>

  {/if}
  </article>
  </div>


