<script lang="ts">
	import PinnedFloats from '../_components/PinnedFloats.svelte';
	import UserActivity from '../_components/UserActivity.svelte';
	import UserHeroSection from '../_components/UserHeroSection.svelte';

	export let data;
</script>

<UserHeroSection userProfile={data.userProfile} userFloats={data.floats} userEvents={data.events} />
{#if data.pinnedFloats && data.pinnedFloats.length > 0}
	<div class="pinned-wrapper">
		<PinnedFloats pinnedFloats={data.pinnedFloats} />
	</div>
{/if}
<UserActivity
	floats={data.floats}
	userProfile={data.userProfile}
	groups={data.groups}
	events={data.events}
/>

<style lang="scss">
	.pinned-wrapper {
		display: none;
		@include mq(small) {
			display: block;
		}
	}
</style>
