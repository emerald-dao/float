<script type="ts">
	import Blur from '$lib/components/Blur.svelte';
	import FloatTicket from '$lib/components/floats/FloatTicket.svelte';
	import type { Event } from '$lib/types/event/event.interface';
	import { Button } from '@emerald-dao/component-library';

	export let event: Event;
</script>

<section class="container">
	<div class="main-wrapper">
		<div class="side-wrapper">
			<h4>{`#${event.eventId}`}</h4>
			<p class="small">Event ID</p>
		</div>
		<div class="event-wrapper">
			<Blur color="tertiary" right="15%" top="10%" />
			<Blur left="15%" top="10%" />
			<FloatTicket float={event} />
		</div>
		<div class="side-wrapper">
			<h4>{`${event.totalSupply}`}</h4>
			<p class="small">FLOATs claimed</p>
		</div>
	</div>
	<div class="container-small details-wrapper">
		<div>
			<p class="large">{`${event.dateCreated}`}</p>
			<p class="small">Start Date</p>
		</div>
		<div>
			<p class="large">06/30/2023</p>
			<p class="small">End Date</p>
		</div>
		<div>
			<p class="large">Free</p>
			<p class="small">Price</p>
		</div>
	</div>
	<Button size="medium" width="extended"><p>Claim FLOAT</p></Button>
</section>

<style type="scss">
	section {
		position: relative;
		display: flex;
		flex-direction: column;
		align-items: center;
		gap: var(--space-13);
		overflow: hidden;

		.main-wrapper {
			display: flex;
			justify-content: center;
			align-items: center;
			text-align: center;
			gap: var(--space-16);

			.side-wrapper {
				display: none;

				@include mq('medium') {
					display: block;
					h4 {
						color: var(--clr-text-main);
					}

					p {
						color: var(--clr-text-off);
					}
				}
			}

			.event-wrapper {
				display: flex;
				flex-direction: column;
				justify-content: center;
				align-items: center;
			}
		}

		.details-wrapper {
			display: grid;
			grid-template-columns: repeat(3, 1fr);
			text-align: center;
			border-top: 1px dashed var(--clr-border-primary);
			border-bottom: 1px dashed var(--clr-border-primary);
			padding: var(--space-5) 0 var(--space-5) 0;

			.small {
				color: var(--clr-text-off);
			}
		}
	}
</style>
