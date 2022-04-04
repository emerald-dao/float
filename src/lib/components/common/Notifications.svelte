<script>
  import { flip } from "svelte/animate";
  import { fly } from "svelte/transition";
  import { notifications } from "$lib/notifications";
</script>

<style>
  .notifications {
    position: fixed;
    top: 10px;
    left: 0;
    right: 0;
    margin: 0 auto;
    padding: 0;
    z-index: 99;
    display: flex;
    flex-direction: column;
    justify-content: flex-start;
    align-items: center;
  }

</style>


<div class="notifications">
  {#each $notifications as notification (notification.id)}
  <div 
    class="alert alert-{notification.type} fade show" 
    role="alert"
    animate:flip
    transition:fly={{ y: -30 }}
  >
    {@html notification.message}
    <!-- <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button> -->
  </div>
  {/each}
</div>