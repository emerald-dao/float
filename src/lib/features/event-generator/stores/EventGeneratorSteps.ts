import { createActiveStep } from '$stores/custom/steps/ActiveStep';
import { createSteps } from '$stores/custom/steps/Steps';
import { createEvent } from '../actions/createEvent';
import {
	EventBasicDataStep,
	FloatImageStep,
	ClaimingOptionsStep,
	TradingOptionsStep,
	PowerUpsStep,
	ReviewStep
} from '../components/steps';

export const eventGeneratorSteps = createSteps([
	{
		name: 'General Data',
		component: EventBasicDataStep,
		title: 'Tell us about your event',
		action: null,
		state: 'active',
		button: {
			text: 'Next',
			icon: 'tabler:arrow-right'
		}
	},
	{
		name: 'General Data',
		component: FloatImageStep,
		title: 'Let’s personalize your FLOAT!',
		action: null,
		state: 'inactive',
		button: {
			text: 'Next',
			icon: 'tabler:arrow-right'
		}
	},
	{
		name: 'Claiming Options',
		component: ClaimingOptionsStep,
		title: 'How will your audience claim their FLOAT?',
		action: null,
		state: 'inactive',
		button: {
			text: 'Next',
			icon: 'tabler:arrow-right'
		}
	},
	{
		name: 'Trading Options',
		component: TradingOptionsStep,
		title: 'Can your audience trade their FLOAT?',
		action: null,
		state: 'inactive',
		button: {
			text: 'Next',
			icon: 'tabler:arrow-right'
		}
	},
	{
		name: 'Power Ups',
		component: PowerUpsStep,
		title: 'Give super powers to your FLOAT',
		action: null,
		state: 'inactive',
		button: {
			text: 'Review Event',
			icon: 'tabler:arrow-right'
		}
	},
	{
		name: 'Review',
		component: ReviewStep,
		title: 'Review your event prior to confirming',
		action: createEvent,
		state: 'inactive',
		button: {
			text: 'Create Event',
			icon: 'tabler:arrow-right'
		}
	}
]);
export const eventGeneratorActiveStep = createActiveStep(eventGeneratorSteps);
