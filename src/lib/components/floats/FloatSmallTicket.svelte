<script type="ts">
	import { Button } from '@emerald-dao/component-library';
	import Icon from '@iconify/svelte';
	import type { FLOAT } from '$lib/types/float/float.interface';
	import { page } from '$app/stores';

	export let float: FLOAT;
</script>

<a class="main-wrapper" href={`/admin/my-collection/${float.eventId}`}>
	<div class="info-wrapper {float.eventId === $page.params.id ? 'selected' : ''}">
		<div class="row-3 details-wrapper">
			<img src={float.eventLogo} width={'54px'} height={'45px'} alt="logo" />
			<div class="column-1">
				<p>{float.eventDescription}</p>
				<span class="small">{float.eventType}</span>
			</div>
		</div>
		<div class="date-wrapper">
			<p class="small">February</p>
			<p class="medium w-semibold">2023</p>
		</div>
	</div>

	<div class="button-wrapper">
		<Button type="transparent" width="no-width">
			<Icon icon="mdi:eye-off-outline" color="var(--clr-neutral-600)" />
		</Button>
	</div>
	<div class="button-wrapper">
		<Button type="transparent" width="no-width">
			<Icon icon="ph:trash" color="var(--clr-alert-main)" />
		</Button>
	</div>
</a>

<style type="scss">
	a {
		text-decoration: none;
		color: unset;
	}
	.main-wrapper {
		display: grid;
		grid-template-columns: 6fr 0.5fr 0.5fr;
		align-items: center;
		gap: var(--space-1);

		.info-wrapper {
			display: flex;
			justify-content: space-between;
			border: var(--border-width-primary) dashed var(--clr-border-primary);
			border-radius: var(--radius-4);
			padding: var(--space-3) var(--space-4);

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

			.date-wrapper {
				background-color: var(--clr-primary-badge);
				border-radius: var(--radius-2);
				padding: var(--space-3);
				text-align: center;

				p {
					color: var(--clr-primary-main);
				}
			}
		}

		.selected {
			background-color: var(--clr-surface-secondary);
			border: var(--border-width-primary) solid var(--clr-border-primary);
		}

		.button-wrapper {
			display: flex;
			justify-content: flex-end;
		}
	}
</style>
