<script>
	import PinnedFloats from '$lib/features/user-public-page/components/PinnedFloats.svelte';
	import UserActivity from '$lib/features/user-public-page/components/UserActivity.svelte';
	import UserHeroSection from '$lib/features/user-public-page/components/UserHeroSection.svelte';

	export let data;
</script>

<UserHeroSection
	userData={data.user}
	floatsClaimed={data.floats.length}
	eventsCreated={data.events.length}
/>
<PinnedFloats pinnedFloats={data.user.pinnedFloats} floats={data.floats} />
<UserActivity floats={data.floats} userData={data.user} />
