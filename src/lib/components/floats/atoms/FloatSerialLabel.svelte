<script lang="ts">
	export let eventId: string;
	export let floatSerial: string;
	export let color: 'primary' | 'gold' | 'silver' | 'bronze' = 'primary';
</script>

<div class={`${color}`}>
	<span>{`#${eventId}`}</span>
	<span>{`${floatSerial}`}</span>
</div>

<style lang="scss">
	div {
		border-radius: 0.5em;
		overflow: hidden;
		display: flex;
		flex-direction: row;
		border: 0.07em solid var(--clr-primary-main);

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

		&.gold {
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

		&.silver {
			border-color: silver;

			span {
				background-color: rgba(192, 192, 192, 0.095);
				color: silver;

				&:last-child {
					background-color: silver;
					color: var(--clr-heading-inverse);
				}
			}
		}

		&.bronze {
			border-color: rgb(205, 127, 50);

			span {
				background-color: rgba(205, 127, 50, 0.095);
				color: rgb(205, 127, 50);

				&:last-child {
					background-color: rgb(205, 127, 50);
					color: var(--clr-heading-inverse);
				}
			}
		}
	}
</style>
