import { toggleTransferringExecution } from "$flow/actions";

const toggleTransfering = async (eventId: string) => {
	return await toggleTransferringExecution(eventId);
};

export default toggleTransfering;
