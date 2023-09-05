import { claimFLOATExecution, logIn } from '$flow/actions';
import { signWithClaimCode } from '$flow/sign';
import { user } from '$stores/flow/FlowStore';
import { get } from 'svelte/store';
import { postClaim } from '../_api/postClaim';

const claimFloat = async (eventId: string, eventCreator: string, claimCode: string | undefined) => {
	const userObject = get(user);

	if (userObject.addr == null) {
		return {
			state: 'error',
			errorMessage: 'Error loading user address'
		};
	}

	if (claimCode) {
		if (!get(user).loggedIn) {
			await logIn();
		}
		const secretSig = await signWithClaimCode(claimCode, userObject.addr);
		return await claimFLOATExecution(eventId, eventCreator, secretSig);
	}

	await postClaim('21339999232', userObject, eventId, eventCreator);

	return await claimFLOATExecution(eventId, eventCreator, null);
};

export default claimFloat;
