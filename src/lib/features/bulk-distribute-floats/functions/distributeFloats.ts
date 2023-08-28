import { distributeFLOATsExecution } from "$flow/actions";

export const distributeFloats = async (eventId: string, addresses: string[]) => {
	return await distributeFLOATsExecution(eventId, addresses);
};
