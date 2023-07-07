export const datesToStatusObject = (
	dateStart: string,
	dateEnding: string
): {
	status: 'NotStarted' | 'InProgress' | 'Completed';
	daysRemaining: number;
} => {
	const currentDate = new Date();
	const startDate = new Date(parseFloat(dateStart) * 1000);
	const endDate = new Date(parseFloat(dateEnding) * 1000);

	if (currentDate < startDate) {
		const timeDiff = startDate.getTime() - currentDate.getTime();
		const daysRemaining = Math.ceil(timeDiff / (1000 * 3600 * 24));
		return {
			status: 'NotStarted',
			daysRemaining: daysRemaining
		};
	} else if (currentDate >= startDate && currentDate <= endDate) {
		const timeDiff = endDate.getTime() - currentDate.getTime();
		const daysRemaining = Math.ceil(timeDiff / (1000 * 3600 * 24));
		return {
			status: 'InProgress',
			daysRemaining: daysRemaining
		};
	} else {
		return {
			status: 'Completed',
			daysRemaining: 0
		};
	}
};
