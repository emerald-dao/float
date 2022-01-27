<script>
  import { user } from "$lib/flow/stores";
  import { logIn } from '$lib/flow/actions';
  
  import { draftFloat } from '$lib/stores';
  
  let timezone = new Date().toLocaleTimeString('en-us',{timeZoneName:'short'}).split(' ')[2];
  
</script>

<style>
  .outline {
    text-align:left;
  }
  
  .outline span {
    display:block;
    font-size: 0.6rem;
    line-height: 1.2;
    font-weight: 400;
    opacity: 0.6;
  }
</style>

<svelte:head>
<title>Create a new FLOAT | Emerald FLOAT</title>
</svelte:head>

<div class="container">
  <article>
    
    <h1 class="mb-1">Create a new FLOAT</h1>
    
    {#if !$user?.loggedIn}
    <div class="mt-2 mb-2">
      <button class="contrast small-button" on:click={logIn}>Connect Wallet</button>
    </div>
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
    
    <div class="grid no-break">
      <button class:secondary={!$draftFloat.claimable} class="outline" on:click={() => $draftFloat.claimable = !$draftFloat.claimable}>
        Claimable
        <span>Users can mint their own FLOAT based on the parameters defined below.</span>
      </button>
      <button class:secondary={$draftFloat.claimable} class="outline" on:click={() => $draftFloat.claimable = !$draftFloat.claimable}>
        Not Claimable
        <span>You will be responsible for distributing the FLOAT to addresses.</span>
      </button>
    </div>
    
    {#if $draftFloat.claimable}
    <!-- QUANTITY -->
    <div class="grid no-break">
      <button class:secondary={$draftFloat.quantity} class="outline" on:click={() => $draftFloat.quantity = !$draftFloat.quantity}>
        Unlimited Quantity
        <span>Select this if you don't want your FLOAT to have a limited quantity.</span>
      </button>
      <button class:secondary={!$draftFloat.quantity} class="outline" on:click={() => $draftFloat.quantity = !$draftFloat.quantity}>
        Limited Quantity
        <span>You can set the maximum number of times the FLOAT can be minted.</span>
        
      </button>
    </div>
    {#if $draftFloat.quantity}
    <label for="quantity">How many can be claimed? 
      <input type="number" name="quantity" bind:value={$draftFloat.quantity} min="1" placeholder="100" />
    </label>
    <hr/>
    {/if}
    
    <!-- TIME -->
    <div class="grid no-break">
      <button class:secondary={$draftFloat.timeBound} class="outline" on:click={() => $draftFloat.timeBound = !$draftFloat.timeBound}>
        No Time Limit
        <span>Can be minted at any point in the future.</span>
      </button>
      <button class:secondary={!$draftFloat.timeBound} class="outline" on:click={() => $draftFloat.timeBound = !$draftFloat.timeBound}>
        Time Limit
        <span>Can only be minted between a specific time interval.</span>
        
      </button>
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
    <div class="grid no-break">
      <button class:secondary={$draftFloat.claimCodeEnabled} class="outline" on:click={() => $draftFloat.claimCodeEnabled = !$draftFloat.claimCodeEnabled}>
        Anyone Can Claim
        <span>Your FLOAT can be minted freely by anyone that knows its address.</span>
      </button>
      <button class:secondary={!$draftFloat.claimCodeEnabled} class="outline" on:click={() => $draftFloat.claimCodeEnabled = !$draftFloat.claimCodeEnabled}>
        Use Claim Code
        <span>Your FLOAT can only be minted if people know the claim code.</span>
      </button>
    </div>
    {#if $draftFloat.claimCodeEnabled}
    <label for="claimCode">Enter a claim code
      <input type="text" name="claimCode" bind:value={$draftFloat.claimCode} placeholder="mySecretCode" />
    </label>
    <hr/>
    {/if}
    {/if}
    {/if}
    
    <footer>
      <button>Create FLOAT</button>
    </footer>
  </article>
</div>


