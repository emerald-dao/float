<script>
  import copy from "copy-to-clipboard";

  export let text = '';
  export let copyConfirmationMessage = "Copied!";

  let copied = false;
  
  function onCopy() {
    copied = true; 
    copy(text);
    setTimeout(() => copied = false, 2000)
  }

</script>

<style>
  .badge {
    cursor:pointer;
  }

  .confirmation {
    font-size: 0.7rem;
  }
</style>

<span class="" on:click={onCopy}>
{#if copied}
  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" width="24" height="24" preserveAspectRatio="xMidYMid meet">
    <path d="M10 15.9L4.7 10.6 3.6 11.6 8.9 16.9 10 18 20.6 7.4 19.5 6.3z"></path>
  </svg>
  <span class="confirmation">{copyConfirmationMessage}</span>
{:else}
<slot></slot>
<svg class="badge" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32" fill="currentColor" width="20" height="20" preserveAspectRatio="xMidYMid meet">
  <path d="M28,10V28H10V10H28m0-2H10a2,2,0,0,0-2,2V28a2,2,0,0,0,2,2H28a2,2,0,0,0,2-2V10a2,2,0,0,0-2-2Z"></path><path d="M4,18H2V4A2,2,0,0,1,4,2H18V4H4Z"></path>
</svg>
{/if}
</span>