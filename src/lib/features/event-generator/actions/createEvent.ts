import captureFloatTicket from '$lib/utilities/captureFloatTicket';
import type { EventGeneratorData } from '../types/event-generator-data.interface';
import type { ActionExecutionResult } from '$stores/custom/steps/step.interface';

export const createEvent = async (): Promise<ActionExecutionResult> => {
	// TODO: Create a new event

	let capturedImageSrc: string;

	let elementToCapture = document.getElementById('target-element');
	let poweredByStyle = document.getElementById('powered-by-style');
	let titleStyle = document.getElementById('title-style');

	capturedImageSrc = await captureFloatTicket(elementToCapture, poweredByStyle, titleStyle);

	alert('I should create a new event');

	// Return an appropriate ActionExecutionResult object
	return {
		state: 'success',
		errorMessage: ''
	};
};
