import type { TimelockStatus } from '../types/verifiers-status.interface';

export const timelockToStatusObject = (dateStart: string, dateEnding: string): TimelockStatus => {
	const currentDate = new Date();
	const startDate = new Date(parseFloat(dateStart) * 1000);
	const endDate = new Date(parseFloat(dateEnding) * 1000);

	if (currentDate < startDate) {
		const timeDiff = startDate.getTime() - currentDate.getTime();
		const daysRemaining = Math.ceil(timeDiff / (1000 * 3600 * 24));
		return {
			status: 'locked',
			remainingTime: daysRemaining
		};
	} else if (currentDate >= startDate && currentDate <= endDate) {
		const timeDiff = endDate.getTime() - currentDate.getTime();
		const daysRemaining = Math.ceil(timeDiff / (1000 * 3600 * 24));
		return {
			status: 'unlocked',
			remainingTime: daysRemaining
		};
	} else {
		return {
			status: 'expired',
			remainingTime: 0
		};
	}
};
