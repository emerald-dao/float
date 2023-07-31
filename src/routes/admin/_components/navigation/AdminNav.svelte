<script lang="ts">
	import { page } from '$app/stores';
	import Icon from '@iconify/svelte';

	let activePage = '';

	$: if ($page.route.id) {
		const pathRegex = /^\/admin\/(events|my-collection)(\/.*)?$/;
		const match = $page.route.id.match(pathRegex);
		activePage = match ? match[1] : '';
	}
</script>

<div class="column-6 container-large">
	<a href="/admin/events" class="sidebar-link" class:active={activePage === 'events'}>
		<Icon icon="tabler:calendar-event" />
		Events
	</a>
	<a href="/admin/my-collection" class="sidebar-link" class:active={activePage === 'my-collection'}>
		<Icon icon="tabler:ticket" />
		My collection
	</a>
</div>

<style lang="scss">
	.column-6 {
		padding: var(--space-6) var(--space-14);
		width: 100%;

		@include mq(medium) {
			border-right: 0.5px solid var(--clr-border-primary);
		}

		.sidebar-link {
			font-size: var(--font-size-3);
			display: flex;

			&.active {
				font-weight: bold;
				color: var(--clr-heading-main);
			}
		}
	}
</style>
