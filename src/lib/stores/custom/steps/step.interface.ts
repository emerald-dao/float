import type { ProgressStates } from '@emerald-dao/component-library/components/ProgressStep/progress-states.type';
import type { SvelteComponent } from 'svelte';

export interface Step {
	name: string;
	title?: string;
	description?: string;
	component: typeof SvelteComponent;
	action: null | (() => Promise<ActionExecutionResult>);
	state: ProgressStates;
	button?: {
		text: string;
		icon?: string;
	};
}

export interface ActionExecutionResult {
	state: 'success' | 'error';
	errorMessage: string;
}
