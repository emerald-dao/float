<script lang="ts">
	import type { FLOAT } from '$lib/types/float/float.interface';
	import PinnedFloats from '../_components/PinnedFloats.svelte';
	import UserActivity from '../_components/UserActivity.svelte';
	import UserHeroSection from '../_components/UserHeroSection.svelte';

	export let data;

	$: hasPinnedFloats = data.pinnedFloats.length > 0 && checkPinnedFloats();

	const checkPinnedFloats = () => {
		let pinnedFloatExists = false;

		for (let i = 0; i < data.pinnedFloats.length; i++) {
			if (data.floats.find((float: FLOAT) => float.id === data.pinnedFloats[i])) {
				pinnedFloatExists = true;
			}
		}

		return pinnedFloatExists;
	};
</script>

<UserHeroSection userProfile={data.userProfile} userFloats={data.floats} userEvents={data.events} />
{#if hasPinnedFloats}
	<div>
		<PinnedFloats pinnedFloats={data.pinnedFloats} floats={data.floats} />
	</div>
{/if}
<UserActivity
	floats={data.floats}
	userProfile={data.userProfile}
	groups={data.groups}
	events={data.events}
/>

<style lang="scss">
	div {
		display: none;

		@include mq(small) {
			display: block;
		}
	}
</style>
