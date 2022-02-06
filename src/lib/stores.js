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
});

// draftFloat.subscribe((value) => {
//   console.log(value)
// })