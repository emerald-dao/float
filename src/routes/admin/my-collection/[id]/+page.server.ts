import { PRIVATE_SUPABASE_SERVICE_ROLE } from '$env/static/private';
import { PUBLIC_SUPABASE_API_URL } from '$env/static/public';
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(PUBLIC_SUPABASE_API_URL, PRIVATE_SUPABASE_SERVICE_ROLE);

export const actions = {
	pinFloat: async ({ request }) => {
		const data = await request.formData();

		const floatId = data.get('floatId') as string;
		const userAddress = data.get('userAddress') as string;
		const network = data.get('network') as string;

		const { error } = await supabase
			.from('pinned_floats')
			.insert({ float_id: floatId, user_address: userAddress, network: network });

		if (error) {
			console.log(error);
		}
	},

	unpinFloat: async ({ request }) => {
		const data = await request.formData();

		const floatId = data.get('floatId') as string;

		const { error } = await supabase.from('pinned_floats').delete().eq('float_id', floatId);

		if (error) {
			console.log(error);
		}
	}
};
