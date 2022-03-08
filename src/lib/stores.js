import { writable } from 'svelte/store';

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
  multipleSecretsEnabled: false
});

export const draftGroup = writable({
  name: '',
  description: '',
  ipfsHash: ''
});


export const theme = writable(null);

export const resolver = persistentWritable('preferredNameResolver', 'fn');

// Make any writable store persistent.
export function persistentWritable(key, defaultValue) {
  // Create a writable store.
  const { subscribe, set, update } = writable();

  // Get stored value.
  const storedValue = localStorage && JSON.parse(localStorage.getItem(key));

  // Determine resolved value.
  const resolvedValue = (storedValue === null) ? defaultValue : storedValue;

  console.log('persistentWritable', key, defaultValue, storedValue, resolvedValue)
  // Set resolved value.
  set(resolvedValue);

  // Subscribe to changes.
  subscribe(value => {
      // Store the new value.
      if (localStorage) {
        localStorage.setItem(key, JSON.stringify(value));
      }
  });

  return { subscribe, set, update };
}