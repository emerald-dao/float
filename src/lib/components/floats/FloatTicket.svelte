<script lang="ts">
	import { Label } from '@emerald-dao/component-library';

	export let title: string;
	export let floatNumber: number;
	export let attendantAddress: string;
	export let eventType: string;
	export let eventOrganizer: string;
</script>

<div class="main-wrapper">
	<div class="secondary-wrapper">
		<div class="header-wrapper">
			<span class="large">FLOAT</span>
			<Label color="tertiary">{`#${floatNumber}`}</Label>
		</div>
		<div class="body-wrapper">
			<span><strong>{attendantAddress}</strong> has attended</span>
			<div class="logo-wrapper row-4">
				<img src="/ec-logo.png" alt="event-logo" />
				<div class="column-2">
					<h3>{title}</h3>
					<Label color="neutral">{eventType}</Label>
				</div>
			</div>
			<span>Organized by <strong>{eventOrganizer}</strong></span>
		</div>
		<div class="footer-wrapper">
			<span class="small">Powered by the Flow Blockchain</span>
		</div>
	</div>
</div>

<style lang="scss">
	.main-wrapper {
		background-color: var(--clr-surface-secondary);
		padding: var(--space-6) var(--space-12);
		border-radius: var(--radius-5);
		width: 700px;

		.secondary-wrapper {
			border: 1px solid var(--clr-border-primary);
			border-radius: var(--radius-4);

			.header-wrapper,
			.footer-wrapper {
				display: flex;
				flex-direction: row;
				align-items: center;
			}

			.header-wrapper {
				padding: var(--space-3) var(--space-10);
				justify-content: space-between;
			}

			.footer-wrapper {
				padding: var(--space-2) var(--space-10);
				justify-content: flex-end;
			}

			.body-wrapper {
				padding: var(--space-5) var(--space-10);
				display: flex;
				flex-direction: column;
				gap: var(--space-6);
				border-block: 1px dashed var(--clr-border-primary);

				.logo-wrapper {
					img {
						width: 80px;
						height: 80px;
					}
				}
			}
		}
	}
</style>
