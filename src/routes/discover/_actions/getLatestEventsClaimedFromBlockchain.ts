import { getEventsBatch } from '$flow/actions';
import { getLatestEventsClaimed } from '../_api/getLatestEventsClaimed';

const getLatestEventsClaimedFromBlockchain = async () => {
	let response = await getLatestEventsClaimed();

	let eventsData = response?.map((event) => {
		return {
			creator_address: event.float_events?.creator_address as string,
			id: event.float_events?.id as string
		};
	});

	if (eventsData) {
		let events = await getEventsBatch(eventsData);

		if (response) {
			let eventsDataWithBlockhainEvent = response.map((claim) => {
				let blockchainEvent = events.find((blockchainEvent) => {
					return blockchainEvent.eventId === claim.event_id;
				});

				return {
					...claim,
					blockchainEvent
				};
			});

			return eventsDataWithBlockhainEvent;
		}
	}

	return [];
};

export default getLatestEventsClaimedFromBlockchain;
