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

let html = document.querySelector('html')
let currentTheme = html.getAttribute('data-theme');
export const theme = writable(currentTheme);

// draftFloat.subscribe((value) => {
//   console.log(value)
// })