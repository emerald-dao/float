import type { EventGeneratorData } from '$lib/features/event-generator/types/event-generator-data.interface';
import { create, test, enforce } from 'vest';

const validationSuite = create((data: EventGeneratorData) => {
	test('limited-amount', 'Amount should be greater than 0', () => {
		enforce(data.powerups.limited.data).greaterThan(0);
	});
});

export default validationSuite;
