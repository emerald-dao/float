<script>
  import LibLoader from "$lib/components/LibLoader.svelte";

  export let unix;

  let countdownString = "";
</script>

<LibLoader
  url="https://cdn.jsdelivr.net/npm/countdown@2.6.0/countdown.min.js"
  on:loaded={() =>
    setInterval(() => (countdownString = countdown(unix * 1000)), 1000)}
  uniqueId={+new Date()}
/>
<span>{countdownString}</span>
