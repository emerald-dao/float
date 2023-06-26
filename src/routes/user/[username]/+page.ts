import { getEvents, getFLOATs } from '$flow/actions.js';
import { getFindProfileFromAddressOrName } from '$flow/utils.js';
import userMock from '../_mock-data/userMock.js';
import usersEventsMock from '../_mock-data/usersEventsMock.js';
import usersFloatsMock from '../_mock-data/usersFloatsMock.js';

export async function load({ params }) {
	const findProfile = await getFindProfileFromAddressOrName(params.username);

	let user = {
		name: '',
		walletAddress: params.username,
		socialMedia: {
			twitter: 'https://twitter.com/JohnDoe',
			instagram: 'https://instagram.com/JohnDoe',
			facebook: 'https://facebook.com/JohnDoe'
		},
		image: '',
		pinnedFloats: ['1', '2']
	};
	if (findProfile) {
		user.name = findProfile.name;
		user.walletAddress = findProfile.address;
		user.image = findProfile.avatar;
	}

	const events = await getEvents(user.walletAddress);
	const floats = await getFLOATs(user.walletAddress);
	return {
		user,
		floats,
		events
	};
}
