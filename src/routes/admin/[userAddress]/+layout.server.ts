export function load({ params }) {
	return {
		status: 302,
		redirect: `/admin/${params.userAddress}/events`
	};
}
