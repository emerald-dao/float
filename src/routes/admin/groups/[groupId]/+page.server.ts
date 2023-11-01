import { serviceSupabase } from '$lib/server/supabaseClient';
import { redirect } from '@sveltejs/kit';

export const actions = {
	addFloatsToGroup: async ({ request }) => {
		const data = await request.formData();

		const groupId = data.get('groupId') as string;
		const floatIdsString = data.get('floatIds') as string;

		const floatIds: string[] = floatIdsString.split(',');

		for (let i = 0; i < floatIds.length; i++) {
			const { error } = await serviceSupabase
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

		const { error } = await serviceSupabase.from('groups').delete().eq('id', groupId);

		if (error) {
			console.log(error);
		}

		throw redirect(302, `/admin/groups`);
	},

	deleteFloatFromGroup: async ({ request }) => {
		const data = await request.formData();

		const groupId = data.get('groupId') as string;
		const floatId = data.get('floatId') as string;

		const { error } = await serviceSupabase
			.from('floats_groups')
			.delete()
			.eq('float_id', floatId)
			.eq('group_id', groupId);

		if (error) {
			console.log(error);
		}
	}
};
