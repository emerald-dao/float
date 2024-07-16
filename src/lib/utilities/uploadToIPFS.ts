import { env as PublicEnv } from '$env/dynamic/public';

export default async function uploadToIpfs(file: File) {
	// First pin the image
	const data = new FormData();
	data.append('file', file);
	const pinFileRes = await fetch('https://api.pinata.cloud/pinning/pinFileToIPFS', {
		method: 'POST',
		headers: {
			Authorization: `Bearer ${PublicEnv.PUBLIC_PINATA_JWT}`
		},
		body: data
	});
	const { IpfsHash: ImageIpfsHash } = await pinFileRes.json();
	return ImageIpfsHash;
}
