export async function getTrendingEvents() {
	try {
		const response = await fetch('/api/events/get-trending-events');
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
