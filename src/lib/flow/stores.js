import { writable, get } from 'svelte/store';

export const user = writable(null);
export const getUser = get(user);
export const transactionStatus = writable(null);
export const txId = writable(null);
export const transactionInProgress = writable(false);

export const eventCreationInProgress = writable(false);
export const eventCreatedStatus = writable(false);

export const floatClaimingInProgress = writable(false);
export const floatClaimedStatus = writable(false);

export const floatDistributingInProgress = writable(false);
export const floatDistributingStatus = writable(false);

export const addSharedMinterInProgress = writable(false);
export const addSharedMinterStatus = writable(false);
export const removeSharedMinterInProgress = writable(false);

export const toggleClaimingInProgress = writable(false);
export const toggleTransferringInProgress = writable(false);

export const addGroupInProgress = writable(false);
export const addGroupStatus = writable(false);