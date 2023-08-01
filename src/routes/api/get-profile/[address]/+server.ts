import type { Profile } from '../../../../lib/types/user/profile.interface';

/** @type {import('./$types').RequestHandler} */
export async function GET({ params, setHeaders }) {
	const profile = await fetch(`https://toucans.ecdao.org/api/get-profile/${params.address}`).then(
		async (data) => (await data.json()) as Profile
	);

	console.log(profile);

	setHeaders({ 'cache-control': 'max-age=14400, public' });

	return new Response(JSON.stringify(profile));
}
