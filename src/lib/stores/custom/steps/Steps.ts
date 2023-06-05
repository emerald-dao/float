import type { ProgressStates } from '@emerald-dao/component-library/components/ProgressStep/progress-states.type';
import { writable } from 'svelte/store';
import type { Step } from './step.interface';

export function createSteps(steps: Step[]) {
	steps.forEach((step, index) => {
		index > 0 ? (step.state = 'inactive') : (step.state = 'active');
	});

	const { subscribe, update, set } = writable(steps);

	function changeStepState(index: number, state: ProgressStates) {
		update((steps) => {
			steps[index].state = state;
			return steps;
		});
	}

	function resetStates() {
		update((steps) => {
			for (let index = 0; index < steps.length; index++) {
				if (index === 0) {
					steps[index].state = 'active';
				} else {
					steps[index].state = 'inactive';
				}
			}
			return steps;
		});
	}

	return {
		subscribe,
		set,
		changeStepState,
		resetStates
	};
}
