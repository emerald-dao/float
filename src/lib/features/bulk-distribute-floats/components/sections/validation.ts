// import { canReceiveToken } from '$flow/actions';
import { create, enforce, test, skipWhen } from 'vest';

const canReceiveToken = async (address: string) => {
	return true;
};

const validationSuite = create((data: string) => {
	test('address', 'Address should have 18 chars', () => {
		enforce(data).lengthEquals(18);
	});

	skipWhen(validationSuite.get().hasErrors('address'), () => {
		test.memo(
			'address',
			"Address doesn't have a vault set up.",
			async () => {
				return (await checkAddress(data)) as string;
			},
			[data]
		);
	});
});

const checkAddress = async (address: string) => {
	return new Promise((resolve, reject) => {
		setTimeout(async () => {
			const success = await canReceiveToken(address);
			if (success) {
				resolve(true);
			} else {
				reject();
			}
		}, 1000);
	});
};

export default validationSuite;
