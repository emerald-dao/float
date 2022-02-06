<script>
  import { authenticate } from '$lib/flow/actions';
</script>

<style>
  a {
    padding: 8px 14px;
  }
</style>

<a role="button" href="/" class="contrast small-button" on:click|preventDefault={authenticate}>Connect Wallet</a>
