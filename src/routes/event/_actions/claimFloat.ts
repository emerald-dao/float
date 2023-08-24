import { claimFLOATExecution, logIn } from "$flow/actions";
import { signWithClaimCode } from "$flow/sign";
import { user } from "$stores/flow/FlowStore";
import { get } from "svelte/store";

const claimFloat = async (eventId: string, eventCreator: string, claimCode: string | undefined) => {
	if (claimCode) {
		if (!get(user).loggedIn) {
			await logIn();
		}
		const secretSig = await signWithClaimCode(claimCode, get(user).addr)
		return await claimFLOATExecution(eventId, eventCreator, secretSig)
	}

	return await claimFLOATExecution(eventId, eventCreator, null)
};

export default claimFloat;
