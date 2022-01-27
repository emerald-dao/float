import { writable } from 'svelte/store';

export const draftFloat = writable({
  claimable: true,
  quantity: false,
  claimCodeEnabled: false,

});