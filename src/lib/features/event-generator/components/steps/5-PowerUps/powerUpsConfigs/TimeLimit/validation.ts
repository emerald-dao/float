import type { EventGeneratorData } from '$lib/features/event-generator/types/event-generator-data.interface';
import { create, test, enforce } from 'vest';

const validationSuite = create((data: EventGeneratorData) => {
	test('start-date', 'Start date should be greater than now', () => {
		enforce(new Date(data.powerups.timelock.data.startDate).getTime()).greaterThan(
			new Date().getTime()
		);
	});

	test('end-date', 'End date should be greater than start date', () => {
		enforce(new Date(data.powerups.timelock.data.endDate).getTime()).greaterThan(
			new Date(data.powerups.timelock.data.startDate).getTime()
		);
	});
});

export default validationSuite;
