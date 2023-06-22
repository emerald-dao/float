import type { EventGeneratorData } from '../types/event-generator-data.interface';

const createEvent = (eventData: EventGeneratorData) => {
	// TODO: Create a new event

	console.log(eventData);

	alert('I should create a new event');
};

export default createEvent;
