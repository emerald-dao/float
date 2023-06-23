import userMock from '../_mock-data/userMock.js';
import usersEventsMock from '../_mock-data/usersEventsMock.js';
import usersFloatsMock from '../_mock-data/usersFloatsMock.js';

export function load() {
	return {
		user: userMock,
		floats: usersFloatsMock,
		events: usersEventsMock
	};
}
