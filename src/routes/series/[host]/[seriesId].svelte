<script>
  import { page } from "$app/stores";
  import { resolveAddressObject } from "$lib/flow/actions";
</script>

<svelte:head>
  <title>EventSeries #{$page.params.seriesId} by {$page.params.host}</title>
</svelte:head>

<div class="container">
  <!-- TODO -->
  <slot />
</div>
