import getLatestEventsClaimedFromBlockchain from './_actions/getLatestEventsClaimedFromBlockchain.js';
import getTrendingEventsFromBlockchain from './_actions/getTrendingEventsFromBlockchain.js';

export async function load({ fetch }) {
	const response = await fetch('/api/events/get-trending-events');

	let trendingEvents = [];

	if (!response.ok) {
		const errorData = await response.json();

		console.error('Error fetching events:', errorData.error);
	} else {
		trendingEvents = (await response.json()).eventsData ?? [];
	}

	return {
		trendingEvents: await getTrendingEventsFromBlockchain(trendingEvents),
		latestFloatsClaimed: await getLatestEventsClaimedAndItsUsers()
	};
}

const getLatestEventsClaimedAndItsUsers = async () => {
	try {
		let latestEventsClaimed = await getLatestEventsClaimedFromBlockchain();

		console.log(latestEventsClaimed);

		return latestEventsClaimed;
	} catch (error) {
		console.error('Error fetching data:', error);

		return [];
	}
};
