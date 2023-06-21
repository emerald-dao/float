<script type="ts">
	import Icon from '@iconify/svelte';
	import type { FLOAT } from '$lib/types/float/float.interface';
	import { page } from '$app/stores';
	import toggleVisibility from '../../_actions/float-actions/toggleFloatVisibility';
	import burnFloat from '../../_actions/float-actions/burnFloat';

	export let float: FLOAT;
</script>

<div class="main-wrapper">
	<a
		class="info-wrapper {float.eventId === $page.params.id ? 'selected' : ''}"
		href={`/admin/my-collection/${float.eventId}`}
	>
		<div class="row-3 details-wrapper">
			<img src={float.eventLogo} width={'54px'} height={'45px'} alt="logo" />
			<div class="column-1">
				<p class="small">{float.eventName}</p>
				<span class="xsmall">{float.eventType}</span>
			</div>
		</div>
		<div class="date-wrapper">
			<p class="xsmall">
				{new Date(float.dateReceived).toLocaleString('default', { month: 'long' })}
			</p>
			<p class="xsmall w-medium">{new Date(float.dateReceived).getFullYear()}</p>
		</div>
	</a>

	<div class="button-wrapper">
		<button class="header-link" on:click={() => toggleVisibility()}>
			<Icon icon="mdi:eye-off-outline" />
		</button>
	</div>
	<div class="button-wrapper">
		<button class="header-link danger" on:click={() => burnFloat()}>
			<Icon icon="ph:trash" />
		</button>
	</div>
</div>

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
				display: flex;
				flex-direction: column;
				background-color: var(--clr-primary-badge);
				border-radius: var(--radius-2);
				padding: var(--space-3);
				text-align: center;
				justify-content: center;

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

			.header-link {
				background-color: transparent;
				border: none;
				padding: 0;

				&.danger {
					color: var(--clr-alert-main);
				}
			}
		}
	}
</style>
