import { toggleClaimingExecution } from "$flow/actions";

const toggleClaiming = async (eventId: string) => {
	return await toggleClaimingExecution(eventId)
};

export default toggleClaiming;
