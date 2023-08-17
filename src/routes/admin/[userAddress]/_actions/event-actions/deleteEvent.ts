import { deleteEventExecution } from "$flow/actions";

const deleteEvent = async (eventId: string) => {
	return await deleteEventExecution(eventId);
};

export default deleteEvent;
