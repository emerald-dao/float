import { getEvent } from '$flow/actions';
import { getLiveEvent } from '../_api/getLiveEvent';

const getLiveEventFromBlockchain = async (eventId: string) => {
	const [response] = await getLiveEvent(eventId);

	if (!response) {
		throw new Error('Response is empty');
	}
	const { id, creator_address } = response;

	const event = await getEvent(creator_address, id);

	return event;
};

export default getLiveEventFromBlockchain;
