import { createActiveStep } from '$stores/custom/steps/ActiveStep';
import { createSteps } from '$stores/custom/steps/Steps';
import { EventBasicDataStep } from '../components/steps';

export const eventGeneratorSteps = createSteps([
	{
		name: 'General Data',
		component: EventBasicDataStep,
		action: null,
		state: 'active'
	}
]);
export const eventGeneratorActiveStep = createActiveStep(eventGeneratorSteps);
