<script lang="ts">
	import type { FLOAT } from '$lib/types/float/float.interface';
	import { unixTimestampToFormattedDate } from '$lib/utilities/dates/unixTimestampToFormattedDate';
	import { Label } from '@emerald-dao/component-library';

	export let float: FLOAT;
	export let selected = false;
	export let clickable: boolean;

	let month = unixTimestampToFormattedDate(float.dateReceived, 'month');
	let year = unixTimestampToFormattedDate(float.dateReceived, 'year');
</script>

<div class="main-wrapper" class:selected class:hover-background={clickable}>
	<div class="row-3 details-wrapper">
		{#if typeof float.eventImage === 'string'}
			<img src={float.eventImage} width="60px" height="60px" alt="logo" />
		{/if}
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
</div>

<style lang="scss">
	.main-wrapper {
		display: flex;
		justify-content: space-between;
		border: 1px solid var(--clr-border-primary);
		border-radius: var(--radius-2);
		padding: var(--space-5) var(--space-6);
		background-color: var(--clr-background-primary);
		transition: all 0.2s ease-in-out;

		&.hover-background {
			&:hover {
				background-color: var(--clr-surface-secondary);
			}
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

		&.selected {
			background-color: var(--clr-surface-secondary);
			box-shadow: 0px 3px 10px 1px var(--clr-shadow-primary);
			border-color: var(--clr-text-primary);
		}
	}
</style>
