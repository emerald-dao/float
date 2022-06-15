import { writable } from 'svelte/store';
import { browser } from '$app/env';

export const draftFloat = writable({
  name: '',
  description: '',
  url: '',
  ipfsHash: '',
  claimable: true,
  timelock: false,
  startTime: false,
  endTime: false,
  quantity: false,
  claimCodeEnabled: false,
  claimCode: '',
  transferrable: true,
  initialGroup: "",
  flowTokenPurchase: false,
});

export const draftGroup = writable({
  name: '',
  description: '',
  ipfsHash: ''
});

export const walletModal = writable(false);

// For Event Series Creation
export const draftEventSeries = writable({
  basics: {
    name: '',
    description: '',
    image: '',
  },
  presetEvents: [],
  emptySlotsAmt: 0,
  emptySlotsRequired: false,
})

export const theme = persistentWritable('theme', 'dark');

export const resolver = persistentWritable('preferredNameResolver', 'find');

export const currentWallet = persistentWritable('currentWallet', 'blocto');

// Make any writable store persistent.
export function persistentWritable(key, defaultValue) {
  // Create a writable store.
  const { subscribe, set, update } = writable();

  let storedValue;
  // Get stored value.
  if (browser) {
    storedValue = localStorage.getItem(key);
  }

  // Determine resolved value.
  const resolvedValue = (storedValue === null) ? defaultValue : storedValue;

  // Set resolved value.
  set(resolvedValue);

  // Subscribe to changes.
  subscribe(value => {
      // Store the new value.
      if (browser) {
        localStorage.setItem(key, value);
      }
  });

  return { subscribe, set, update };
}