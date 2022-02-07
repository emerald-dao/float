<svelte:head>
  <script bind:this={script} src={url} />
</svelte:head>

<script>
  import { createEventDispatcher, afterUpdate } from 'svelte';

  const dispatch = createEventDispatcher();
  export let url;
  export let uniqueId;
  let script;

  afterUpdate(async () => {
  
    script.addEventListener('load', () => {
      dispatch('loaded');
    })

    console.log(uniqueId);

    script.addEventListener('error', (event) => {
      console.error("something went wrong", event);
      dispatch('error');
    });
  });
</script>