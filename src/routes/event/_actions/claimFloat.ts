import { claimFLOATExecution } from "$flow/actions";

const claimFloat = async (eventId: string, eventCreator: string) => {
	return await claimFLOATExecution(eventId, eventCreator)
};

export default claimFloat;
