<script type="ts">
	import { page } from '$app/stores';
	import AdminHeader from './_components/navigation/AdminHeader.svelte';
	import AdminNav from './_components/navigation/AdminNav.svelte';

	let route: string | null;

	function extractSecondPart(route: string): string | null {
		const regex = /^\/\w+\/(.+)$/;
		const matches = route.match(regex);
		if (matches && matches.length === 2) {
			return matches[1];
		}
		return null;
	}

	$: route = typeof $page.route.id === 'string' ? extractSecondPart($page.route.id) : null;
</script>

<AdminHeader {route} />

<div class="container-large">
	<div class="nav-wrapper">
		<AdminNav />
	</div>
	<div class="main-wrapper">
		<slot />
	</div>
</div>

<style type="scss">
	.container-large {
		display: flex;
		flex-direction: column;
		gap: var(--space-8);
		overflow: hidden;
		height: 200vh;

		@include mq(medium) {
			display: grid;
			grid-template-columns: 160px auto;
			gap: var(--space-8);
		}

		.nav-wrapper {
			border-right: 2px solid var(--clr-neutral-900);
		}

		.main-wrapper {
			padding-block: var(--space-6);
		}
	}
</style>
