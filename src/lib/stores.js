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
  multipleSecretsEnabled: false,
  initialGroup: ""
});

export const draftGroup = writable({
  name: '',
  description: '',
  ipfsHash: ''
});


export const theme = persistentWritable('theme', 'dark');

export const resolver = persistentWritable('preferredNameResolver', 'fn');

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

  console.log('persistentWritable', key, defaultValue, storedValue, resolvedValue)
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