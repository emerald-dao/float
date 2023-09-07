import { hasFLOATCollectionSetUp } from '$flow/actions';
import { getFindProfileFromAddressOrName } from '$flow/utils';
import { create, enforce, test, skipWhen } from 'vest';

const validationSuite = create((data: string) => {
	enforce(data).isNotEmpty();

	skipWhen(validationSuite.get().hasErrors('address'), () => {
		test.memo(
			'address',
			"Address doesn't exist.",
			async () => {
				return await checkAddress(data);
			},
			[data]
		);
	});
});

const checkAddress = async (address: string): Promise<string> => {
	return new Promise(async (resolve, reject) => {
		const profile = await getFindProfileFromAddressOrName(address);

		if (profile) {
			const success = await hasFLOATCollectionSetUp(profile.address);

			if (success) {
				resolve(`Address has a FLOAT Collection set up.`);
			} else {
				reject(`Address doesn't have a FLOAT Collection set up.`);
			}
		} else if (address.length === 18 && address.startsWith('0x')) {
			const success = await hasFLOATCollectionSetUp(address);

			if (success) {
				resolve(`Address has a FLOAT Collection set up.`);
			} else {
				reject(`Address doesn't have a FLOAT Collection set up.`);
			}
		} else {
			reject(`Address or name is invalid.`);
		}
	});
};

export default validationSuite;
