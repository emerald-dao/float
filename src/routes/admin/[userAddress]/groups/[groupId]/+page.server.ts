import { PRIVATE_SUPABASE_SERVICE_ROLE } from '$env/static/private';
import { PUBLIC_SUPABASE_API_URL } from '$env/static/public';
import { createClient } from '@supabase/supabase-js';
import { redirect } from '@sveltejs/kit';

const supabase = createClient(PUBLIC_SUPABASE_API_URL, PRIVATE_SUPABASE_SERVICE_ROLE);

export const actions = {
	addFloatsToGroup: async ({ request }) => {
		const data = await request.formData();

		const groupId = data.get('groupId') as string;
		const floatIdsString = data.get('floatIds') as string;

		const floatIds: string[] = floatIdsString.split(',');

		for (let i = 0; i < floatIds.length; i++) {
			// if float is not in the floats table, add it
			const { error: floatError } = await supabase.from('floats').insert({ id: floatIds[i] });

			if (floatError) {
				console.log(floatError);
			}

			const { error } = await supabase
				.from('floats_groups')
				.insert({ float_id: floatIds[i], group_id: groupId });

			if (error) {
				console.log(error);
			}
		}
	},

	deleteGroup: async ({ request, params }) => {
		const data = await request.formData();

		const groupId = data.get('groupId') as string;

		const { error } = await supabase.from('groups').delete().eq('id', groupId);

		if (error) {
			console.log(error);
		}

		throw redirect(302, `/admin/${params.userAddress}/groups`);
	},

	deleteFloatFromGroup: async ({ request }) => {
		const data = await request.formData();

		const groupId = data.get('groupId') as string;
		const floatId = data.get('floatId') as string;

		const { error } = await supabase
			.from('floats_groups')
			.delete()
			.eq('float_id', floatId)
			.eq('group_id', groupId);

		if (error) {
			console.log(error);
		}
	}
};
