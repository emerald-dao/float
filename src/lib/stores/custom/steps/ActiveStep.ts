import { get, writable } from 'svelte/store';
import type { Subscriber, Unsubscriber } from 'svelte/store';
import type { ProgressStates } from '@emerald-dao/component-library/components/ProgressStep/progress-states.type';
import type { Step } from './step.interface';

export function createActiveStep(steps: {
	subscribe: (this: void, run: Subscriber<Step[]>) => Unsubscriber;
	changeStepState: (index: number, state: ProgressStates) => void;
	resetStates: () => void;
}) {
	const activeStep = writable(0);
	const { subscribe, set, update } = activeStep;

	async function increment() {
		const activeStepNumber = get(activeStep);
		const action = get(steps)[activeStepNumber].action;
		const numberOfSteps = get(steps).length;

		if (numberOfSteps - 1 >= activeStepNumber) {
			if (action != null) {
				steps.changeStepState(activeStepNumber, 'loading');

				const actionResult = await action();

				if (actionResult.state === 'error') {
					steps.changeStepState(activeStepNumber, 'error');
					console.error('Error in action: ' + actionResult.errorMessage);
					return;
				} else if (actionResult.state === 'success') {
					steps.changeStepState(activeStepNumber, 'success');
					if (numberOfSteps - 1 !== activeStepNumber) {
						steps.changeStepState(activeStepNumber + 1, 'active');
						update((n) => n + 1);
					}
				}
			} else {
				steps.changeStepState(activeStepNumber, 'success');
				if (numberOfSteps - 1 !== activeStepNumber) {
					steps.changeStepState(activeStepNumber + 1, 'active');
					update((n) => n + 1);
				}
			}
		}
	}

	function decrement() {
		const activeStepNumber = get(activeStep);

		if (activeStepNumber > 0) {
			steps.changeStepState(activeStepNumber - 1, 'active');
			steps.changeStepState(activeStepNumber, 'inactive');
			update((n) => n - 1);
		}
	}

	function goToStep(i: number) {
		for (let j = i + 1; j < get(steps).length; j++) {
			steps.changeStepState(j, 'inactive');
		}
		steps.changeStepState(i, 'active');
		set(i);
	}

	function reset() {
		set(0);
		steps.resetStates();
	}

	return {
		subscribe,
		increment,
		decrement,
		goToStep,
		reset
	};
}
