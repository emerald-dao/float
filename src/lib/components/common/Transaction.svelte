<script>
import { transactionStatus, transactionInProgress } from "$lib/flow/stores";
import { slide } from 'svelte/transition';
</script>

<style>
  progress {
    margin-top:1em;
  }

  small {
    opacity:0.8;
  }
</style>
{#if $transactionInProgress}
<article class="card accent-border" transition:slide>
  Transaction status:
  {#if $transactionStatus < 0}
  <span><kbd>Initializing</kbd><br/><small>Waiting for transaction approval.</small></span>
  <progress indeterminate>Initializing...</progress>
  {:else if $transactionStatus < 2}
  <span><kbd>Pending</kbd><br/><small>The transaction has been received by a collector but not yet finalized in a block.</small></span>
  <progress indeterminate>Executing</progress>
  {:else if $transactionStatus === 2}
  <span><kbd>Finalized</kbd><br/><small>The consensus nodes have finalized the block that the transaction is included in.</small></span>
  <progress min="0" max="100" value="80">Executing...</progress>
  {:else if $transactionStatus === 3}
  <span><kbd>Executed</kbd><br/><small>	The execution nodes have produced a result for the transaction.</small></span>
  <progress min="0" max="100" value="80">Sealing...</progress>
  {:else if $transactionStatus === 4}
  <span><kbd>✓ Sealed</kbd><br/><small>The verification nodes have verified the transaction, and the seal is included in the latest block.</small></span>
  <progress min="0" max="100" value="100">Sealed!</progress>
  {:else if $transactionStatus === 5}
  <span><kbd>Expired</kbd><br/><small>The transaction was submitted past its expiration block height.</small></span>
  {:else}
  <span data-theme="invalid">Error!</span>
  {/if}
  <small><a href="https://docs.onflow.org/access-api/">More info</a></small>
</article>
{/if}