import { getEventsBatch } from '$flow/actions';
import { getLatestEventsClaimed } from '../_api/getLatestEventsClaimed';

const getLatestEventsClaimedFromBlockchain = async () => {
	let response = await getLatestEventsClaimed();

	let events = await getEventsBatch(response.eventsData);

	return {
		events,
		latestUsersToClaim: response.latestUsersToClaim
	};
};

export default getLatestEventsClaimedFromBlockchain;
