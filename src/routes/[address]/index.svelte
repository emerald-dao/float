<script>
  import { page } from '$app/stores';
  import Meta from '$lib/components/common/Meta.svelte';

  import AccountContents from '$lib/components/AccountContents.svelte';
  import CheckAddress from '$lib/components/CheckAddress.svelte';
</script>

<style>

</style>

<Meta
title="FLOATs owned by {$page.params.address}"
author={$page.params.address}
description="FLOATs owned by {$page.params.address}"
url={window.location}
/>

<div class="container">
	
  <h1 class="mb-1">{$page.params.address}'s Account</h1>
  <AccountContents address={$page.params.address} />

  <h3 class="mt-1">Check another address</h3>
  <CheckAddress />
	
</div>

