<script lang="ts">
	import { fly } from 'svelte/transition';
	import type { Event } from '$lib/types/event/event.interface';
	import Domain from './atoms/Domain.svelte';
	import Actions from './atoms/Actions.svelte';
	import EventInfo from './EventInfo.svelte';

	export let event: Event;
	export let claims;
	export let user: {};
</script>

<div class="main-wrapper" in:fly={{ x: 10, duration: 400 }}>
	<div class="left-wrapper">
		<div class="header-wrapper">
			<div class="row-3">
				<img src={event.image} alt="logo" height="57" width="68" />
				<h4>{event.name}</h4>
			</div>
			<span class="small">{event.eventType}</span>
		</div>
		<Domain {event} {user} />
		<Actions />
	</div>
	<div class="right-wrapper">
		<EventInfo {claims} {event} />
	</div>
</div>

<style lang="scss">
	.main-wrapper {
		display: flex;
		flex-direction: column;
		justify-content: center;

		@include mq(medium) {
			display: grid;
			grid-template-columns: 2fr 3fr;
			justify-content: center;
			gap: var(--space-6);
		}

		.left-wrapper {
			display: flex;
			flex-direction: column;
			gap: var(--space-10);
			padding: var(--space-6) 0;
			border-bottom: 4px solid var(--clr-border-primary);

			@include mq(medium) {
				border-bottom: none;
			}

			.header-wrapper {
				display: flex;
				flex-direction: column;
				gap: var(--space-2);

				.row-3 {
					align-items: center;
				}

				span {
					text-align: center;
					width: fit-content;
					border: var(--border-width-primary) solid var(--clr-border-primary);
					padding: var(--space-1) var(--space-2);
					border-radius: var(--radius-2);
				}
			}
		}

		.right-wrapper {
			@include mq(medium) {
				background-color: var(--clr-background-secondary);
			}
		}
	}
</style>
