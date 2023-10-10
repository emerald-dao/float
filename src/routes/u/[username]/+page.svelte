<script lang="ts">
	import { network } from '$flow/config';
	import PinnedFloats from '../_components/PinnedFloats.svelte';
	import UserActivity from '../_components/UserActivity.svelte';
	import UserHeroSection from '../_components/UserHeroSection.svelte';

	export let data;

	$: thisNetworkPinnedFloats =
		data.pinnedFloats?.filter((float) => float.network === network) ?? [];

	$: pinnedFloats =
		thisNetworkPinnedFloats?.length > 0
			? data.floats.filter((float) =>
					thisNetworkPinnedFloats.some((pinnedFloat) => pinnedFloat.float_id === float.id)
			  )
			: [];
</script>

<UserHeroSection userProfile={data.userProfile} userFloats={data.floats} userEvents={data.events} />
{#if pinnedFloats && pinnedFloats.length > 0}
	<PinnedFloats {pinnedFloats} />
{/if}
<UserActivity
	floats={data.floats}
	userProfile={data.userProfile}
	groups={data.groups}
	events={data.events}
/>
