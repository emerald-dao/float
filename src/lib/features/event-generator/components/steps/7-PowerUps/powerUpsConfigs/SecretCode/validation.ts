import type { EventGeneratorData } from '$lib/features/event-generator/types/event-generator-data.interface';
import { create, test, enforce } from 'vest';

const validationSuite = create((data: EventGeneratorData) => {
	test('secret-code', 'Secret code should be longer than 2', () => {
		enforce(data.powerups.secret.data).longerThan(2);
	});

	test('secret-code', 'Secret code should be shorter than 30', () => {
		enforce(data.powerups.secret.data).shorterThan(30);
	});
});

export default validationSuite;
