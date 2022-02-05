<script>
  import { page } from '$app/stores';
  import { PAGE_TITLE_EXTENSION } from '$lib/constants'

  import CheckAddress from '$lib/components/CheckAddress.svelte';
</script>

<style>
  article {
  margin-top:10px;
}
</style>

<svelte:head>
	<title>Claim {$page.params.address}'s Event FLOAT #{$page.params.eventId}</title>
</svelte:head>

<div class="container">
	<h1>Claim {$page.params.address}'s Event FLOAT #{$page.params.eventId}</h1>

  <div class="grid">
    <!-- Populate with FLOATs that this address has claimed -->
    <article></article>
    <article></article>
    <article></article>
    <article></article>
    <article></article>
  </div>

  <h1>Events by {$page.params.address}</h1>

  <div class="grid">
    <!-- Populate with FLOAT events that this address has created-->
    <article></article> <!-- can be active or expired? -->
    <article></article>
    <article></article>
    <article></article>
    <article></article>
  </div>

  <h2>Check another address</h2>

  <CheckAddress />
	
</div>

