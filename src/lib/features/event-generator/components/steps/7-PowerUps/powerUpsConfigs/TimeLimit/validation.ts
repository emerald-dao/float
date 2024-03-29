import type { EventGeneratorData } from '$lib/features/event-generator/types/event-generator-data.interface';
import { create, test, enforce } from 'vest';

const validationSuite = create((data: EventGeneratorData) => {
	test('start-date', 'Start date should be greater than now', () => {
		enforce(data.powerups.timelock.data.dateStart).greaterThan(
			Math.floor(new Date().getTime() / 1000).toString()
		);
	});

	test('end-date', 'End date should be greater than start date', () => {
		enforce(data.powerups.timelock.data.dateEnding).greaterThan(data.powerups.timelock.data.dateStart);
	});
});

export default validationSuite;
