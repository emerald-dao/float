<script>
	import PinnedFloats from '../_components/PinnedFloats.svelte';
	import UserActivity from '../_components/UserActivity.svelte';
	import UserHeroSection from '../_components/UserHeroSection.svelte';

	export let data;
</script>

<UserHeroSection
	userData={data.user}
	floatsClaimed={data.floats.length}
	eventsCreated={data.events.length}
/>
{#if data.user.pinnedFloats.length > 0}
	<div>
		<PinnedFloats pinnedFloats={data.user.pinnedFloats} floats={data.floats} />
	</div>
{/if}
<UserActivity floats={data.floats} userData={data.user} />

<style lang="scss">
	div {
		display: none;

		@include mq(small) {
			display: block;
		}
	}
</style>
