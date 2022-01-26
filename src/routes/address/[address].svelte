<script>
  import { page } from '$app/stores';
  import CheckAddress from '$lib/components/CheckAddress.svelte';
</script>

<style>
  article {
  margin-top:10px;
}
</style>

<svelte:head>
	<title>Address</title>
</svelte:head>

<div class="container">
	<h1>FLOATs of {$page.params.address}</h1>

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

