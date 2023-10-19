import { writable } from 'svelte/store';
import type { TransactionStatusObject } from '@onflow/fcl';

function createTransaction(transaction: TransactionStatusObject) {
  const { subscribe, set } = writable({
    progress: false,
    transaction: transaction,
    transactionId: ''
  });

  function initTransaction() {
    set({
      progress: true,
      transaction: transaction,
      transactionId: ''
    });
  }

  function subscribeTransaction(transaction: TransactionStatusObject, transactionId: string) {
    set({
      progress: true,
      transaction: transaction,
      transactionId
    });
  }

  function resetTransaction() {
    set({
      progress: false,
      transaction: transaction,
      transactionId: ''
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