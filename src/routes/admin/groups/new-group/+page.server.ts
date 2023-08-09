import { PRIVATE_SUPABASE_SERVICE_ROLE } from '$env/static/private';
import { PUBLIC_SUPABASE_API_URL } from '$env/static/public';
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(PUBLIC_SUPABASE_API_URL, PRIVATE_SUPABASE_SERVICE_ROLE);

export const actions = {
	default: async ({ request }) => {
		const data = await request.formData();

		const groupName = data.get('name') as string;
		const groupDescription = data.get('description') as string | undefined;
		const userAddress = data.get('user_address') as string;

		const { data: user } = await supabase.from('users').select('id').eq('address', userAddress);

		if (!user) {
			await supabase.from('users').insert({ address: userAddress });
		}

		const { error } = await supabase
			.from('groups')
			.insert({ name: groupName, description: groupDescription, user_address: userAddress });

		if (error) {
			return {
				status: 500,
				body: {
					error
				}
			};
		}
	}
};
