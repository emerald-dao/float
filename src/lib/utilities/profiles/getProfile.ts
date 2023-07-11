import type { Profile } from '$lib/types/user/profile.interface';

const getProfile = async (address: string) =>
	await fetch(`/api/get-profile/${address}`).then(async (data) => (await data.json()) as Profile);

export default getProfile;
