<script lang="ts">
	import { user } from '$lib/stores/flow/FlowStore';
	import { page } from '$app/stores';
	import Icon from '@iconify/svelte';
</script>

<div class="container-large">
	<div class="column-7">
		<a
			href={`/admin/${$page.params.userAddress}/events`}
			class="sidebar-link"
			class:active={$page.url.pathname.includes('/events')}
		>
			<Icon icon="tabler:calendar-event" />
			Events
		</a>
		<a
			href={`/admin/${$page.params.userAddress}/my-collection`}
			class="sidebar-link"
			class:active={$page.url.pathname.includes('/my-collection')}
		>
			<Icon icon="tabler:ticket" />
			My collection
		</a>
		<a
			href={`/admin/${$page.params.userAddress}/groups`}
			class="sidebar-link"
			class:active={$page.url.pathname.includes('/groups')}
		>
			<Icon icon="tabler:packages" />
			Groups
		</a>
	</div>

	<a href={`/u/${$user.addr}`} class="sidebar-link">
		<Icon icon="tabler:user" />
		My profile
	</a>
</div>

<style lang="scss">
	.container-large {
		display: none;
		padding: var(--space-6) var(--space-14);
		width: 100%;
		flex-direction: column;
		justify-content: space-between;

		@include mq(small) {
			display: flex;
			padding: var(--space-4) var(--space-6);
			border-bottom: 0.5px solid var(--clr-border-primary);
			gap: var(--space-8);
		}

		@include mq(medium) {
			border-right: 0.5px solid var(--clr-border-primary);
			display: flex;
			padding: var(--space-7) var(--space-14);
			border-bottom: 0.5px solid var(--clr-border-primary);
			gap: var(--space-10);
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
