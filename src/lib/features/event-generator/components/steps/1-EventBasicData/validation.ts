import { create, test, enforce, only } from 'vest';

const validationSuite = create((data = {}, currentField?) => {
	if (currentField) {
		only(currentField);
	}

	test('event-name', 'Event name is required', () => {
		enforce(data.name).isNotBlank();
	});

	test('event-name', 'Event name must be at least 3 characters long', () => {
		enforce(data.name).longerThan(3);
	});
});

export default validationSuite;
