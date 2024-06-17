export async function getLatestEventsClaimed() {
	try {
		const response = await fetch('/api/events/get-latest-events-claimed');
		if (!response.ok) {
			const errorData = await response.json();
			console.error('Error fetching events:', errorData.error);
			return null;
		}

		const responseData:
			| {
					event_id: string | null;
					user_address: string;
					float_id: string;
					serial: string;
					float_events: {
						created_at: string | null;
						creator_address: string;
						id: string;
					} | null;
			  }[]
			| null = await response.json();

		return responseData;
	} catch (error) {
		console.error('Error fetching events:', error);
		return null;
	}
}
