<script type="ts">
	import { Button } from '@emerald-dao/component-library';
	import Icon from '@iconify/svelte';
	import type { Event } from '$lib/types/event/event.interface';

	export let event: Event;
</script>

<a class="main-wrapper" href={`/admin/events/${event.eventId}`}>
	<div class="left-wrapper">
		<div class="row-3 details-wrapper">
			<img src={event.image} width={'54px'} height={'45px'} alt="logo" />
			<div class="column-1">
				<p>{event.description}</p>
				<span class="small">{event.eventType}</span>
			</div>
		</div>
		<div>
			<p>{event.totalSupply} FLOATs claimed</p>
		</div>
	</div>
	<div class="right-wrapper">
		<div class="status-wrapper">
			<Icon icon="ion:ellipse-sharp" color="var(--clr-primary-main)" />
			<p class="xsmall">active</p>
		</div>
		<p>20 days left</p>
	</div>
</a>

<style type="scss">
	a {
		text-decoration: none;
		color: unset;
	}

	.main-wrapper {
		display: grid;
		grid-template-columns: 0.9fr 1fr;
		justify-content: space-between;
		border: var(--border-width-primary) solid var(--clr-border-primary);
		border-radius: var(--radius-4);
		padding: var(--space-3) var(--space-4);
		background: var(--clr-surface-primary);

		.left-wrapper {
			display: grid;
			grid-template-columns: 1.1fr 1fr;
			align-items: center;
			gap: var(--space-7);

			.details-wrapper {
				align-items: center;
				.column-1 {
					p {
						text-align: left;
						color: var(--clr-heading-main);
					}

					span {
						text-align: center;
						width: fit-content;
						border: var(--border-width-primary) solid var(--clr-border-primary);
						padding: var(--space-1);
						border-radius: var(--radius-1);
					}
				}
			}
		}

		.right-wrapper {
			display: flex;
			justify-content: flex-end;
			align-items: center;
			gap: var(--space-2);

			.status-wrapper {
				display: flex;
				align-items: center;
				height: fit-content;
				background-color: var(--clr-primary-badge);
				padding: var(--space-1) var(--space-2);
				border-radius: var(--radius-1);
				text-align: center;
				gap: var(--space-1);

				p {
					color: var(--clr-primary-main);
				}
			}
		}
	}
</style>
