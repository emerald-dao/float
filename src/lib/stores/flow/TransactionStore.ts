import { writable } from 'svelte/store';
import type { TransactionStatusObject } from '@blocto/fcl';

function createTransaction(transaction: TransactionStatusObject) {
  const { subscribe, set } = writable({
    progress: false,
    transaction: transaction
  });

  function initTransaction() {
    set({
      progress: true,
      transaction: transaction
    });
  }

  function subscribeTransaction(transaction: TransactionStatusObject) {
    set({
      progress: true,
      transaction: transaction
    });
  }

  function resetTransaction() {
    set({
      progress: false,
      transaction: transaction
    });
  }

  return {
    subscribe,
    initTransaction,
    subscribeTransaction,
    resetTransaction
  };
}

export const transactionStore = createTransaction({
  blockId: '',
  events: [],
  status: -1,
  statusString: '',
  errorMessage: '',
  statusCode: 1
});