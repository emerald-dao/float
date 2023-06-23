import eventMock from '../../_mock-data/oneEventMock';
import claims from '../../_mock-data/floatClaimsMock';

export function load() {
	return {
		event: eventMock,
		eventClaims: claims
	};
}
