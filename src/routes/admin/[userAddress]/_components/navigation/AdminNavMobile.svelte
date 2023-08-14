<script lang="ts">
	import { page } from '$app/stores';
	import Icon from '@iconify/svelte';

	console.log($page);
</script>

<div class="container-large">
	<a class="new-event-button shadow-medium" href="/event-generator">+</a>
	<a
		href={`/admin/${$page.params.userAddress}/events`}
		class="header-link"
		class:active={$page.url.pathname.includes('/events')}
	>
		<Icon icon="tabler:calendar-event" width="19px" />
		Events
	</a>
	<a
		href={`/admin/${$page.params.userAddress}/my-collection`}
		class="header-link"
		class:active={$page.url.pathname.includes('/my-collection')}
	>
		<Icon icon="tabler:ticket" width="19px" />
		My Collection
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

<style lang="scss">
	.container-large {
		padding: var(--space-4) var(--space-14);
		width: 100%;
		display: grid;
		grid-template-columns: repeat(2, 1fr);
		gap: var(--space-12);
		position: fixed;
		bottom: 0;
		align-items: center;
		justify-content: center;
		background-color: var(--clr-surface-secondary);
		box-shadow: 0px 0px 10px 0px var(--clr-shadow-primary);
		z-index: 99;
		border-radius: var(--radius-4) var(--radius-4) 0 0;

		@include mq(small) {
			display: none;
		}

		.header-link {
			font-size: var(--font-size-0);
			display: flex;
			flex-direction: column;
			align-items: center;
			justify-content: center;
			text-align: center;
			gap: var(--space-1);

			&.active {
				font-weight: bold;
				color: var(--clr-primary-main);
			}
		}

		.new-event-button {
			color: var(--clr-heading-inverse);
			width: 50px;
			height: 50px;
			border-radius: 50%;
			display: flex;
			align-items: center;
			justify-content: center;
			background-color: var(--clr-primary-main);
			text-decoration: none;
			transition: all 0.3s ease-in-out;
			font-size: var(--font-size-4);
			position: absolute;
			top: -22.5px;
			left: calc(50% - 25px);
		}
	}
</style>
