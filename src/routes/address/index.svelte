<script>
  import CheckAddress from '$lib/components/CheckAddress.svelte'
  import { PAGE_TITLE_EXTENSION } from '$lib/constants'
</script>
<svelte:head>
	<title>Find Your Event { PAGE_TITLE_EXTENSION }</title>
</svelte:head>

<div class="container">
	<h1>Find your event</h1>
	<CheckAddress />
</div>

