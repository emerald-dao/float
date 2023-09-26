import { create, test, enforce, only } from 'vest';

const validationSuite = create((data = {}, currentField) => {
	only(currentField);

	test('event-name', 'Event name is required', () => {
		enforce(data.name).isNotBlank();
	});

	test('event-name', 'Event name must be at least 3 characters long', () => {
		enforce(data.name).longerThan(3);
	});

	test('event-description', 'Event description should be shorter than 320 chars', () => {
		enforce(data.description).shorterThan(320);
	})
});

export default validationSuite;
