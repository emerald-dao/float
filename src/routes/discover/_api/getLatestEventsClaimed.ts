export async function getLatestEventsClaimed() {
	try {
		const response = await fetch('/api/events/get-latest-events-claimed');
		if (!response.ok) {
			const errorData = await response.json();
			console.error('Error fetching events:', errorData.error);
			return null;
		}

		const responseData = await response.json();

		return responseData;
	} catch (error) {
		console.error('Error fetching events:', error);
		return null;
	}
}
