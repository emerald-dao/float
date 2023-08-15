import captureFloatTicket from '$lib/utilities/captureFloatTicket';
import type { EventGeneratorData } from '../types/event-generator-data.interface';
import type { ActionExecutionResult } from '$stores/custom/steps/step.interface';
import { get } from 'svelte/store';
import { eventGeneratorData } from '../stores/EventGeneratorData';
import { createEventExecution } from '$flow/actions';
import uploadToIPFS from '$lib/utilities/uploadToIPFS';

export const createEvent = async (): Promise<ActionExecutionResult> => {
	// TODO: Create a new event
	let event = get(eventGeneratorData)
	console.log(event)

	let capturedImageSrc: string;

	let elementToCapture = document.getElementById('target-element');
	let poweredByStyle = document.getElementById('powered-by-style');
	let titleStyle = document.getElementById('title-style');

	capturedImageSrc = await captureFloatTicket(elementToCapture, poweredByStyle, titleStyle);
	console.log(capturedImageSrc)

	if (event.logo.length == 0 || event.image.length == 0) {
		return {
			state: 'error',
			errorMessage: 'Need to provide a logo and back image'
		};
	}

	const logoIpfsCid = await uploadToIPFS(event.logo[0]);
	const backImageIpfsCid = await uploadToIPFS(event.image[0])

	await createEventExecution(
		event.name,
		event.description,
		event.url,
		logoIpfsCid,
		backImageIpfsCid,
		event.transferrable,
		event.claimable,
		event.eventType,
		event.powerups.timelock.active ? event.powerups.timelock.data : null,
		event.powerups.secretCode.active ? event.powerups.secretCode.data : null,
		event.powerups.limited.active ? event.powerups.limited.data : null,
		event.powerups.payment.active ? event.powerups.payment.data : null,
		event.powerups.minimumBalance.active ? event.powerups.minimumBalance.data : null
	)

	// Return an appropriate ActionExecutionResult object
	return {
		state: 'success',
		errorMessage: ''
	};
};
