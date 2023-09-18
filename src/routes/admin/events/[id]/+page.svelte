<script lang="ts">
	import { fly } from 'svelte/transition';
	import EventDomains from '../atoms/EventDomains.svelte';
	import EventActions from '../atoms/EventActions.svelte';
	import EventInfo from './_components/EventDetails.svelte';
	import FloatEventType from '$lib/components/floats/atoms/FloatEventType.svelte';
	import { getContext } from 'svelte';
	import type { EventWithStatus } from '$lib/types/event/event.interface';
	import { page } from '$app/stores';
	import type { Writable } from 'svelte/store';

	const eventsWithStatus: Writable<EventWithStatus[]> = getContext('events');

	$: event = $eventsWithStatus.find((event) => event.eventId === $page.params.id);
</script>

{#if event}
	<div class="main-wrapper" in:fly={{ x: 10, duration: 400 }}>
		<div class="left-wrapper">
			<div class="header-wrapper">
				<div class="row-4 align-center">
					<img src={event.image} alt="logo" height="70" width="70" />
					<div class="column-1">
						<h4 class="w-medium">{event.name}</h4>
						<FloatEventType eventType={event.eventType} fontSize="1em" />
					</div>
				</div>
			</div>
			<EventDomains {event} />
			<EventActions {event} />
		</div>
		<div class="right-wrapper hide-on-small">
			<EventInfo {event} />
		</div>
	</div>
{:else}
	<p class="center">
		<em> Upsss.. we couldn't find this event </em>
	</p>
{/if}

<style lang="scss">
	.main-wrapper {
		display: flex;
		flex-direction: column;
		justify-content: center;
		overflow: hidden;

		@include mq(medium) {
			display: grid;
			grid-template-columns: 2fr 3fr;
		}

		.left-wrapper {
			display: flex;
			flex-direction: column;
			gap: var(--space-10);
			padding: var(--space-6) 0 var(--space-6) 0;
			box-shadow: 5px 2px 8px -6px var(--clr-shadow-primary);
			z-index: 1;

			.header-wrapper {
				display: flex;
				flex-direction: column;
				gap: var(--space-2);
				padding-inline: var(--space-8);

				img {
					border-radius: var(--radius-0);
				}
			}
		}

		.right-wrapper {
			border-left: var(--clr-border-primary) 0.5px solid;
			overflow: hidden;

			@include mq(medium) {
				background-color: var(--clr-background-secondary);
			}
		}
	}

	.hide-on-small {
		display: none;

		@include mq(small) {
			display: block;
		}
	}
</style>
