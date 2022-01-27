<script>
  import { logIn } from '$lib/flow/actions';
</script>

<style>
  a {
    padding: 8px 14px;
  }
</style>

<a role="button" href="/" class="contrast small-button" on:click|preventDefault={logIn}>Connect Wallet</a>
