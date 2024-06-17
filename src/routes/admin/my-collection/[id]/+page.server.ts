import { serviceSupabase } from '$lib/server/supabaseClient';

export const actions = {
	pinFloat: async ({ request }) => {
		const data = await request.formData();

		const floatId = data.get('floatId') as string;
		const userAddress = data.get('userAddress') as string;
		const network = data.get('network') as string;

		const { error } = await serviceSupabase
			.from('float_pinned_floats')
			.insert({ float_id: floatId, user_address: userAddress, network: network });

		if (error) {
			console.log(error);
		}
	},

	unpinFloat: async ({ request }) => {
		const data = await request.formData();

		const floatId = data.get('floatId') as string;

		const { error } = await serviceSupabase
			.from('float_pinned_floats')
			.delete()
			.eq('float_id', floatId);

		if (error) {
			console.log(error);
		}
	}
};
