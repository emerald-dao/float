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
<div>
	<PinnedFloats pinnedFloats={data.user.pinnedFloats} floats={data.floats} />
</div>
<UserActivity floats={data.floats} userData={data.user} />

<style type="scss">
	div {
		display: none;

		@include mq(small) {
			display: block;
		}
	}
</style>
