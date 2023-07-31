<script lang="ts">
	import { page } from '$app/stores';
	import AdminHeader from './_components/navigation/AdminHeader.svelte';
	import AdminNav from './_components/navigation/AdminNav.svelte';
	import '@emerald-dao/component-library/styles/app.scss';

	export let data;

	let route: string | null;

	function extractSecondPart(route: string): string | null {
		const regex = /^\/\w+\/([^\/]+)(?:\/|$)/;
		const matches = route.match(regex);
		if (matches && matches.length === 2) {
			return matches[1];
		}
		return null;
	}

	$: route = typeof $page.route.id === 'string' ? extractSecondPart($page.route.id) : null;
</script>

<div class="main-wrapper">
	<AdminHeader {route} userName={data.user.name} userAvatar={data.user.avatar} />
	<div class="secondary-wrapper">
		<AdminNav />
		<slot />
	</div>
</div>

<style lang="scss">
	.main-wrapper {
		@include mq(medium) {
			max-height: 100vh;
			flex: 1;
			display: flex;
			flex-direction: column;
		}

		.secondary-wrapper {
			display: flex;
			flex-direction: column;
			flex: 1;
			overflow: hidden;

			@include mq(medium) {
				display: grid;
				grid-template-columns: 1fr 4fr;
			}
		}
	}
</style>
