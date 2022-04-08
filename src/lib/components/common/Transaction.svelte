<script>
  import {
    txId,
    transactionStatus,
    transactionInProgress,
  } from "$lib/flow/stores";
  import { slide } from "svelte/transition";
</script>

{#if $transactionInProgress}
  <article
    class="accent-border {$transactionStatus == 99 ? 'error' : null}"
    transition:slide
  >
    {#if $transactionStatus < 0}
      <span>
        <kbd>Initializing</kbd><br/>
        <small>Waiting for transaction approval.</small>
      </span>
      <progress indeterminate>Initializing...</progress>
    {:else if $transactionStatus < 2}
      <span>
        <kbd>Pending</kbd>
        <span class="txId">
          <a href={`https://flowscan.org/transaction/${$txId}`} target="_blank">
            {$txId?.slice(0, 8)}...
          </a>
        </span><br/>
        <small>
          The transaction has been received by a collector but not yet finalized
          in a block.
        </small>
      </span>
      <progress indeterminate>Finalizing...</progress>
    {:else if $transactionStatus === 2}
      <span>
        <kbd>Finalized</kbd>
        <span class="txId">
          <a href={`https://flowscan.org/transaction/${$txId}`} target="_blank">
            {$txId?.slice(0, 8)}...
          </a>
        </span><br/>
        <small>The consensus nodes have finalized the block that the transaction is included in.</small>
      </span>
      <progress min="0" max="100" value="60">Executing...</progress>
    {:else if $transactionStatus === 3}
    <span>
      <kbd>Executed</kbd>
      <span class="txId">
        <a href={`https://flowscan.org/transaction/${$txId}`} target="_blank">
          {$txId?.slice(0, 8)}...
        </a>
      </span><br/>
      <small>
        The execution nodes have produced a result for the transaction.
      </small>
    </span>
      <progress min="0" max="100" value="80">Sealing...</progress>
    {:else if $transactionStatus === 4}
    <span>
      <kbd>✓ Sealed</kbd>
      <span class="txId">
        <a href={`https://flowscan.org/transaction/${$txId}`} target="_blank">
          {$txId?.slice(0, 8)}...
        </a>
      </span><br/>
      <small>The verification nodes have verified the transaction, and the seal is included in the latest block.</small>
    </span>
      <progress min="0" max="100" value="100">Sealed!</progress>
    {:else if $transactionStatus === 5}
    <span>
      <kbd>Expired</kbd>
      <span class="txId">
        <a href={`https://flowscan.org/transaction/${$txId}`} target="_blank">
          {$txId?.slice(0, 8)}...
        </a>
      </span><br/>
      <small>The transaction was submitted past its expiration block height.</small>
    </span>
    {:else}
      <span data-theme="invalid">
        Unexpected parameters were passed into the transaction.
      </span>
    {/if}
    <!-- <small><a href="https://docs.onflow.org/access-api/">More info</a></small> -->
  </article>
{/if}

<style>
  article {
    padding: 1rem;
    margin: 0;
    position: fixed;
    left: 10px;
    bottom: 10px;
    font-size: 0.7rem;
  }

  span {
    font-size: 0.7rem;
  }

  progress {
    margin-top: 0.5rem;
    margin-bottom: 0;
  }

  small {
    opacity: 0.8;
  }

  .txId {
    margin-left: 10px;
  }

  @media screen and (max-width: 600px) {
    article {
      right: 10px;
    }
  }
</style>
