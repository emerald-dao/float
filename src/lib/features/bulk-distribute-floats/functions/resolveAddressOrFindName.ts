import { getFindProfileFromAddressOrName } from '$flow/utils';

export const resolveAddressOrFindName = async (address: string) => {
	if (address.startsWith('0x') && address.length === 18) {
		return address;
	} else {
		const profile = await getFindProfileFromAddressOrName(address);
		if (profile) {
			return profile.address;
		}
	}
};
