import type { ActionExecutionResult } from '$stores/custom/steps/step.interface';
import { get } from 'svelte/store';
import {
	EMPTY_GENERATOR_DATA,
	eventGeneratorData
} from '$lib/features/event-generator/stores/EventGeneratorData';
import { createEventExecution } from '$flow/actions';
import uploadToIPFS from '$lib/utilities/uploadToIPFS';
import { eventGenerationInProgress } from '../stores/EventGenerationInProgress';
import { postEvent } from '../api/postEvent';
import { user } from '$stores/flow/FlowStore';
import type { TransactionStatusObject } from '@onflow/fcl';
import { goto } from '$app/navigation';
import { eventGeneratorActiveStep } from '../stores/EventGeneratorSteps';

export const createEvent = async (): Promise<ActionExecutionResult> => {
	eventGenerationInProgress.set(true);

	const event = get(eventGeneratorData);
	const userObject = get(user);

	if (userObject.addr == null) {
		return {
			state: 'error',
			errorMessage: 'Error loading user address'
		};
	}

	if (event.logo.length == 0 || event.image.length == 0 || event.ticketImage == null) {
		return {
			state: 'error',
			errorMessage: 'Error loading event images'
		};
	}

	const logoIpfsCid = await uploadToIPFS(event.logo[0]);
	const backImageIpfsCid = await uploadToIPFS(event.image[0]);

	let floatTicketIpfsCid:
		| string
		| {
			gold: string;
			silver: string;
			bronze: string;
			participation: string;
		};

	if (event.certificateType === 'medal') {
		floatTicketIpfsCid = {
			gold: await uploadToIPFS(event.ticketImage.gold),
			silver: await uploadToIPFS(event.ticketImage.silver),
			bronze: await uploadToIPFS(event.ticketImage.bronze),
			participation: await uploadToIPFS(event.ticketImage.participation)
		};
	} else {
		floatTicketIpfsCid = await uploadToIPFS(event.ticketImage as File);
	}

	// After the new event is created, save event to database
	const actionAfterCreateEvent: (
		res: TransactionStatusObject
	) => Promise<ActionExecutionResult> = async (res: TransactionStatusObject) => {
		const [eventCreated] = res.events.filter((event) =>
			event.type.includes('FLOAT.FLOATEventCreated')
		);
		const eventData = eventCreated.data;
		const eventId = eventData.eventId;

		await postEvent(eventId, userObject);

		await goto(`/admin/events/${eventId}`);

		eventGeneratorActiveStep.reset();
		eventGeneratorData.set(EMPTY_GENERATOR_DATA);

		return {
			state: 'success',
			errorMessage: ''
		};
	};

	await createEventExecution(
		event.name,
		event.description,
		event.url,
		logoIpfsCid,
		backImageIpfsCid,
		floatTicketIpfsCid,
		event.transferrable,
		event.claimable,
		event.eventType,
		event.certificateType,
		event.powerups.timelock.active ? event.powerups.timelock.data : null,
		event.powerups.secret.active ? event.powerups.secret.data : null,
		event.powerups.limited.active ? event.powerups.limited.data : null,
		event.powerups.payment.active ? event.powerups.payment.data : null,
		event.powerups.minimumBalance.active ? event.powerups.minimumBalance.data : null,
		event.powerups.requireEmail.active,
		event.visibilityMode,
		event.multipleClaim,
		actionAfterCreateEvent
	);

	eventGenerationInProgress.set(false);

	// Return an appropriate ActionExecutionResult object
	return {
		state: 'success',
		errorMessage: ''
	};
};
