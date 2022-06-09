<script>
  import { PAGE_TITLE_EXTENSION } from "$lib/constants";
  import { page } from "$app/stores";
  import { resolveAddressObject } from "$lib/flow/actions";
</script>

<svelte:head>
  <title>EventSeries #{$page.params.seriesId} {PAGE_TITLE_EXTENSION}</title>
</svelte:head>

<div class="">
  <slot />
</div>
