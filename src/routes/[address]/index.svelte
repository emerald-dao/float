<script>
  import { page } from '$app/stores';
  import { PAGE_TITLE_EXTENSION } from '$lib/constants'

  import AccountContents from '$lib/components/AccountContents.svelte';
  import CheckAddress from '$lib/components/CheckAddress.svelte';
</script>

<style>

</style>

<svelte:head>
	<title>FLOATs of {$page.params.address} { PAGE_TITLE_EXTENSION }</title>
</svelte:head>

<div class="container">
	
  <h1 class="mb-1">{$page.params.address}'s Account</h1>
  <AccountContents address={$page.params.address} />

  <h3 class="mt-1">Check another address</h3>
  <CheckAddress />
	
</div>

