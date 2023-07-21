<script lang="ts">
	import { page } from '$app/stores';
	import AdminHeader from './_components/navigation/AdminHeader.svelte';
	import AdminNav from './_components/navigation/AdminNav.svelte';

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

<AdminHeader {route} userName={data.user.name} userAvatar={data.user.avatar} />

<div class="main-container">
	<div />
	<div class="nav-wrapper">
		<AdminNav />
	</div>
	<div class="main-wrapper">
		<slot />
	</div>
</div>

<style lang="scss">
	.main-container {
		display: flex;
		flex-direction: column;

		@include mq(medium) {
			display: grid;
			grid-template-columns: 0.15fr 0.25fr 2fr;
			gap: var(--space-8);
		}

		.nav-wrapper {
			border-bottom: 1px solid var(--clr-neutral-700);

			@include mq(medium) {
				border-bottom: none;
				border-right: 1px solid var(--clr-neutral-700);
			}
		}
	}
</style>
