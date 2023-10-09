<script lang="ts">
	import PinnedFloats from '../_components/PinnedFloats.svelte';
	import UserActivity from '../_components/UserActivity.svelte';
	import UserHeroSection from '../_components/UserHeroSection.svelte';

	export let data;
</script>

<UserHeroSection userProfile={data.userProfile} userFloats={data.floats} userEvents={data.events} />
{#if data.pinnedFloats && data.pinnedFloats.length > 0}
	<PinnedFloats pinnedFloats={data.pinnedFloats} />
{/if}
<UserActivity
	floats={data.floats}
	userProfile={data.userProfile}
	groups={data.groups}
	events={data.events}
/>
