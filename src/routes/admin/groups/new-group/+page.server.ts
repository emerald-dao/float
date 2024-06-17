import { serviceSupabase } from '$lib/server/supabaseClient';
import { redirect } from '@sveltejs/kit';

export const actions = {
	default: async ({ request, params }) => {
		const formData = await request.formData();

		const groupName = formData.get('name') as string;
		const groupDescription = formData.get('description') as string | undefined;
		const userAddress = formData.get('user_address') as string;

		const { data: user } = await serviceSupabase
			.from('users')
			.select('id')
			.eq('address', userAddress);

		if (!user) {
			await serviceSupabase.from('users').insert({ address: userAddress });
		}

		const { data, error } = await serviceSupabase
			.from('float_groups')
			.insert({ name: groupName, description: groupDescription, user_address: userAddress });

		console.log(error);

		if (error) {
			return {
				status: 500,
				body: {
					error
				}
			};
		} else {
			throw redirect(302, `/admin/groups/${data[0].id}`);
		}
	}
};
