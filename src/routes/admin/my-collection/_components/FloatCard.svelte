<script lang="ts">
	import type { FLOAT } from '$lib/types/float/float.interface';
	import { page } from '$app/stores';
	import { unixTimestampToFormattedDate } from '$lib/utilities/dates/unixTimestampToFormattedDate';
	import { Label } from '@emerald-dao/component-library';

	export let float: FLOAT;

	let month = unixTimestampToFormattedDate(float.dateReceived, 'month');
	let year = unixTimestampToFormattedDate(float.dateReceived, 'year');
</script>

<div class="main-wrapper">
	<a
		class="info-wrapper {float.eventId === $page.params.id ? 'selected' : ''}"
		class:selected={float.eventId === $page.params.id}
		href={`/admin/my-collection/${float.eventId}`}
	>
		<div class="row-3 details-wrapper">
			<img src={float.eventImage} width="60px" height="60px" alt="logo" />
			<div class="column-1">
				<p class="event-name w-medium">{float.eventName}</p>
				<Label color="neutral" size="xx-small" hasBorder={false}>{float.eventType}</Label>
			</div>
		</div>
		<div class="date-wrapper">
			<div class="label-wrapper">
				<span class="xsmall">
					{month}
				</span>
				<span class="xsmall w-medium">{year}</span>
			</div>
		</div>
	</a>
</div>

<style lang="scss">
	a {
		text-decoration: none;
		color: unset;
		transition: 300ms ease-in-out;
	}

	.main-wrapper {
		.info-wrapper {
			display: flex;
			justify-content: space-between;
			border: var(--border-width-primary) solid var(--clr-border-primary);
			border-radius: var(--radius-2);
			padding: var(--space-5) var(--space-6);

			&:hover {
				background-color: var(--clr-surface-secondary);
			}

			.details-wrapper {
				align-items: center;
				display: flex;
				gap: var(--space-3);

				img {
					border-radius: var(--radius-0);
				}

				.event-name {
					max-width: 25ch;
				}

				.column-1 {
					p {
						text-align: left;
						color: var(--clr-heading-main);
					}

					span {
						text-align: center;
						width: fit-content;
						border: var(--border-width-primary) solid var(--clr-border-primary);
						padding: var(--space-1) var(--space-2);
						border-radius: var(--radius-1);
					}
				}
			}

			.date-wrapper {
				display: flex;
				flex-direction: row;
				text-align: center;
				justify-content: center;
				align-items: center;

				.label-wrapper {
					height: min-content;
					background-color: var(--clr-primary-badge);
					border-radius: var(--radius-2);
					padding: var(--space-1) var(--space-4);
				}

				span {
					color: var(--clr-primary-main);
					align-self: center;
				}
			}
		}

		.selected {
			background-color: var(--clr-surface-secondary);
			border: var(--border-width-primary) solid var(--clr-border-primary);
			box-shadow: 0px 0px 10px 0 var(--clr-shadow-primary);
		}
	}
</style>
