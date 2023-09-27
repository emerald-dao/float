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
import MultipleClaimStep from '../components/steps/5-MultipleClaim/MultipleClaimStep.svelte';
import VisibilityOptions from '../components/steps/6-VisibilityOptions/VisibilityOptions.svelte';

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
		},
		canBeEditedLater: false
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
		},
		canBeEditedLater: false
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
		},
		canBeEditedLater: true
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
		},
		canBeEditedLater: true
	},
	{
		name: 'Multiple Claim',
		component: MultipleClaimStep,
		title: 'How many FLOATs can each user claim?',
		action: null,
		state: 'inactive',
		button: {
			text: 'Next',
			icon: 'tabler:arrow-right'
		},
		canBeEditedLater: false
	},
	{
		name: 'Visibility Options',
		component: VisibilityOptions,
		title: 'How do you want your FLOAT to be seen?',
		action: null,
		state: 'inactive',
		button: {
			text: 'Next',
			icon: 'tabler:arrow-right'
		},
		canBeEditedLater: true
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
		},
		canBeEditedLater: false
	},
	{
		name: 'Review',
		component: ReviewStep,
		title: 'Launch your event!',
		action: createEvent,
		state: 'inactive',
		button: {
			text: 'Create Event',
			icon: 'tabler:arrow-right'
		}
	}
]);
export const eventGeneratorActiveStep = createActiveStep(eventGeneratorSteps);
