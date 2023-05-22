import { createActiveStep } from '$stores/custom/steps/ActiveStep';
import { createSteps } from '$stores/custom/steps/Steps';
import { EventBasicDataStep, FloatImage } from '../components/steps';

export const eventGeneratorSteps = createSteps([
	{
		name: 'General Data',
		component: EventBasicDataStep,
		title: 'Tell us about your event',
		description: 'This information will let us know more about your event',
		action: null,
		state: 'active',
		button: {
			text: 'Next',
			icon: 'tabler:arrow-right'
		}
	},
	{
		name: 'General Data',
		component: FloatImage,
		action: null,
		state: 'active',
		button: {
			text: 'Next',
			icon: 'tabler:arrow-right'
		}
	}
]);
export const eventGeneratorActiveStep = createActiveStep(eventGeneratorSteps);
