import type { Profile } from '$lib/types/user/profile.interface';

export const fetchProfile = async (address: string) => {
	const userProfile = await fetch(`https://toucans.ecdao.org/api/get-profile/${address}`).then(
		async (data) => (await data.json()) as Profile
	);

	return userProfile;
};
