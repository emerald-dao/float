import type { EventGeneratorData } from '../types/event-generator-data.interface';

const createEvent = (eventData: EventGeneratorData) => {
	console.log(eventData);

	alert('I create a new event!');
};

export default createEvent;
