import { writable } from 'svelte/store';

export const user = writable(null);
export const userNames = writable(null);
export const transactionStatus = writable(null);
export const txId = writable(null);
export const transactionInProgress = writable(false);

export const eventCreationInProgress = writable(false);
export const eventCreatedSuccessfully = writable(false);

export const floatClaimingInProgress = writable(false);
export const floatClaimedSuccessfully = writable(false);