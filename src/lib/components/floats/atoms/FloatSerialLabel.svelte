<script lang="ts">
	import type { CertificateType } from '$lib/types/event/event-type.type';

	export let eventId: string;
	export let floatSerial: string;
	export let certificateType: CertificateType;
</script>

<div class:medal={certificateType === 'medal'}>
	<span>{`#${eventId}`}</span>
	<span>{`${floatSerial}`}</span>
</div>

<style lang="scss">
	div {
		border-radius: 0.5em;
		overflow: hidden;
		display: flex;
		flex-direction: row;
		border: 1px solid var(--clr-primary-main);

		span {
			font-size: 0.67em;
			background-color: var(--clr-primary-badge);
			color: var(--clr-primary-main);
			--font-weight: var(--font-weight-medium);
			width: fit-content;
			padding: 0.4em 0.8em 0.4em 1em;
			line-height: normal;
			font-family: var(--font-mono);

			&:last-child {
				background-color: var(--clr-primary-main);
				color: var(--clr-heading-inverse);
				padding: 0.4em 1em 0.4em 0.8em;
			}
		}

		&.medal {
			border-color: goldenrod;

			span {
				background-color: rgba(218, 165, 32, 0.095);
				color: goldenrod;

				&:last-child {
					background-color: goldenrod;
					color: var(--clr-heading-inverse);
				}
			}
		}
	}
</style>
