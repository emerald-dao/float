import { redirect } from '@sveltejs/kit';
import { getFLOATs } from '../../../flow/actions';

export const load = async () => {
	const floats = await getFLOATs('0x99bd48c8036e2876');
	throw redirect(302, `/admin/my-collection/${floats[0].eventId}`);
};
