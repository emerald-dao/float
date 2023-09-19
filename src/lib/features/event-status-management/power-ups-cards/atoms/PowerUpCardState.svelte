<script lang="ts">
	export let message: string;
	export let status: 'active' | 'neutral' | 'inactive' = 'neutral';
</script>

<div class={`main-wrapper ${status}`}>
	<span class="w-medium">{message}</span>
</div>

<style lang="scss">
	.main-wrapper {
		padding: 0.3em 1em;
		display: flex;
		justify-content: center;
		align-items: center;
		text-align: center;
		border-top: 1px dashed var(--clr-neutral-badge);
		background-color: var(--clr-surface-secondary);

		span {
			padding-top: 0.1em;
			font-size: 0.59em;
			line-height: 0.9;
		}

		&.inactive {
			background-color: var(--clr-alert-badge);

			span {
				color: var(--clr-alert-main);
			}
		}

		&.active {
			background-color: var(--clr-primary-badge);

			span {
				color: var(--clr-success-main);
			}
		}
	}
</style>
