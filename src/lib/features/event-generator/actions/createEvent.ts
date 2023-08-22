import type { ActionExecutionResult } from '$stores/custom/steps/step.interface';
import { get } from 'svelte/store';
import { eventGeneratorData } from '../stores/EventGeneratorData';
import { createEventExecution } from '$flow/actions';
import uploadToIPFS from '$lib/utilities/uploadToIPFS';

export const createEvent = async (): Promise<ActionExecutionResult> => {
	let event = get(eventGeneratorData);

	if (event.logo.length == 0 || event.image.length == 0 || event.ticketImage == null) {
		return {
			state: 'error',
			errorMessage: 'Error loading event images'
		};
	}

	const logoIpfsCid = await uploadToIPFS(event.logo[0]);
	const backImageIpfsCid = await uploadToIPFS(event.image[0]);
	const floatTicketIpfsCid = await uploadToIPFS(event.ticketImage);

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
	);

	// Return an appropriate ActionExecutionResult object
	return {
		state: 'success',
		errorMessage: ''
	};
};
