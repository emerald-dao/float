<script>
  import { user } from "$lib/flow/stores";
  import { logIn } from '$lib/flow/actions';
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

<!-- Range slider -->
  <label for="Claim">Claim Type</label>
  <select id="Claim" required>
    <option value="" selected>Select a claim type...</option>
    <option>Open: Anyone can claim this FLOAT until the host turns it off</option>
    <option>Secret Code: Host will not have to type anything upon creation of the event because the code comes afterwards</option>
<option>Capacity: An unlimited number of FLOATs can be created until too many people have claimed. A Capacity must be provided.</option>
<option>Time Limit: Anyone can claim until time is over. A length of time must be provided.</option>
<option>Custom: You will manually distribute the FLOAT.</option>
  </select>


  <div class="grid">
    <!-- Date -->
    <label for="start">Start
      <input type="datetime-local" id="start" name="start">
    </label>
    
    <!-- Date -->
    <label for="start">End
      <input type="datetime-local" id="start" name="start">
    </label>
  </div>

  <button>Create FLOAT</button>

  {/if}
  </article>
  </div>


