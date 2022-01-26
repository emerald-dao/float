<script>
  import { profile } from '$lib/flow/stores';
  import { 
    executeTransaction 
  } from '$lib/flow/actions';

  /**
   * Example profile object:
   * {
   *  address: '0x0d1f73bb7bdca8b9', 
   *  name: 'Flow Developer', 
   *  avatar: '', 
   *  color: '#232323', 
   *  info: ''
   * }
  */
</script>


<article class="card">

  <label for="address">
    Address
    <input type="text" id="address" name="address" value="{$profile.address}" placeholder="Address" disabled>
  </label>
  <div class="grid">

    <label for="name">
      Name
      <input type="text" id="name" name="name" placeholder="Name" bind:value={$profile.name}>
    </label>
    
    <label for="color">
      Favorite Color
      <input type="color" id="color" name="color" bind:value={$profile.color}>
    </label>
    
  </div>
  
  <label for="info">Bio</label>
  <textarea type="info" id="info" name="info" placeholder="Your personal info" bind:value={$profile.info}></textarea>

  <button on:click={executeTransaction}>Update Profile</button>

</article>