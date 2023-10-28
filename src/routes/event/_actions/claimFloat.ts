import { claimFLOATExecution, logIn } from '$flow/actions';
import { signWithClaimCode, submitEmailAndGetSig } from '$flow/sign';
import { user } from '$stores/flow/FlowStore';
import { get } from 'svelte/store';
import { postClaim } from '../_api/postClaim';
import type { TransactionStatusObject } from '@onflow/fcl';
import type { ActionExecutionResult } from '$stores/custom/steps/step.interface';

const claimFloat = async (eventId: string, eventCreator: string, claimCode: string | undefined, email: string | undefined, free: boolean) => {
	const userObject = get(user);

	if (userObject.addr == null) {
		return {
			state: 'error',
			errorMessage: 'Error loading user address'
		};
	}

	// After the FLOAT is claimed, save claim to database
	const actionAfterClaimFloat: (
		res: TransactionStatusObject
	) => Promise<ActionExecutionResult> = async (res: TransactionStatusObject) => {
		const [floatClaimedEvent] = res.events.filter((event) =>
			event.type.includes('FLOAT.FLOATClaimed')
		);
		const { id, serial } = floatClaimedEvent.data;

		await postClaim(
			id,
			userObject,
			eventId,
			eventCreator,
			res.blockId,
			floatClaimedEvent.transactionId,
			serial
		);

		return {
			state: 'success',
			errorMessage: ''
		};
	};

	let secretSig = null;
	let emailSig = null;

	if (claimCode) {
		if (!get(user).loggedIn) {
			await logIn();
		}
		secretSig = await signWithClaimCode(claimCode, userObject.addr);
	}

	if (email) {
		if (!get(user).loggedIn) {
			await logIn();
		}
		emailSig = await submitEmailAndGetSig(email, userObject.addr, eventId);
	}

	return await claimFLOATExecution(eventId, eventCreator, secretSig, emailSig, free, actionAfterClaimFloat);
};

export default claimFloat;
