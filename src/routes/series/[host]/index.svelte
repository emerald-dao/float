<script>
  import { page } from "$app/stores";
  import Meta from "$lib/components/common/Meta.svelte";
  import { resolveAddressObject } from "$lib/flow/actions";

  $: addressObject = resolveAddressObject($page.params.host);
</script>

<Meta
  title="EventSeries hosted by {$page.params.host}"
  author={$page.params.host}
  description="EventSeries hosted by {$page.params.host}"
  url={$page.url}
/>

<div>ALL Series</div>
