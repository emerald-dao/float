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
	<title>FLOATs of {$page.params.address} { PAGE_TITLE_EXTENSION }</title>
</svelte:head>

<div class="container">
	<h1>Claimed FLOATs of {$page.params.address}</h1>

  <div class="grid">
    <article></article>
    <article></article>
    <article></article>
    <article></article>
    <article></article>
  </div>

  <h1>Events by {$page.params.address}</h1>

  <div class="grid">
    <article></article>
    <article></article>
    <article></article>
    <article></article>
    <article></article>
  </div>

  <h2>Check another address</h2>

  <CheckAddress />
	
</div>

