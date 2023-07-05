<script lang="ts">
	import { Button } from '@emerald-dao/component-library';
	import Icon from '@iconify/svelte';
	import type { Event } from '$lib/types/event/event.interface';

	export let event: Event;
</script>

<a class="main-wrapper" href={`/admin/events/${event.eventId}`}>
	<div class="top-wrapper">
		<div class="row-3 details-wrapper">
			<img src={event.image} width={'54px'} height={'45px'} alt="logo" />
			<div class="column-1">
				<p class="large">{event.description}</p>
				<span class="small">{event.eventType}</span>
			</div>
		</div>
		<div>
			<p class="large">{event.totalSupply} FLOATs claimed</p>
		</div>
	</div>
	<div class="bottom-wrapper">
		<div class="status-wrapper">
			<Icon icon="ion:ellipse-sharp" color="var(--clr-primary-main)" />
			<p class="xsmall">active</p>
		</div>
		<p>20 days left</p>
	</div>
</a>

<style lang="scss">
	a {
		text-decoration: none;
		color: unset;
		word-break: break-word;
	}

	.main-wrapper {
		display: flex;
		flex-direction: column;
		justify-content: space-between;
		gap: var(--space-9);
		border: var(--border-width-primary) solid var(--clr-border-primary);
		border-radius: var(--radius-4);
		background: var(--clr-surface-primary);

		.top-wrapper {
			display: flex;
			flex-direction: column;
			justify-content: center;
			gap: var(--space-7);
			padding: var(--space-8) var(--space-10) 0;

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

		.bottom-wrapper {
			display: flex;
			justify-content: space-between;
			align-items: center;
			border-top: var(--border-width-primary) dashed var(--clr-border-primary);
			padding: var(--space-4) var(--space-10) var(--space-5);

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
