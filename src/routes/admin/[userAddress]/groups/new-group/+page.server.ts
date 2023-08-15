import { PRIVATE_SUPABASE_SERVICE_ROLE } from '$env/static/private';
import { PUBLIC_SUPABASE_API_URL } from '$env/static/public';
import { createClient } from '@supabase/supabase-js';
import { redirect } from '@sveltejs/kit';

const supabase = createClient(PUBLIC_SUPABASE_API_URL, PRIVATE_SUPABASE_SERVICE_ROLE);

export const actions = {
	default: async ({ request, params }) => {
		const formData = await request.formData();

		const groupName = formData.get('name') as string;
		const groupDescription = formData.get('description') as string | undefined;
		const userAddress = formData.get('user_address') as string;

		const { data: user } = await supabase.from('users').select('id').eq('address', userAddress);

		if (!user) {
			await supabase.from('users').insert({ address: userAddress });
		}

		const { data, error } = await supabase
			.from('groups')
			.insert({ name: groupName, description: groupDescription, user_address: userAddress })
			.select();

		if (error) {
			return {
				status: 500,
				body: {
					error
				}
			};
		} else {
			throw redirect(302, `/admin/${params.userAddress}/groups/${data[0].id}`);
		}
	}
};
