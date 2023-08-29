import { writable, type Writable } from 'svelte/store';

export const eventGenerationInProgress = writable(false);
