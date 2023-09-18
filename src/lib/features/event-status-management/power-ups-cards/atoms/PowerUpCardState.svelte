<script lang="ts">
	export let message: string;
	export let status: 'active' | 'neutral' | 'inactive' = 'neutral';
</script>

<div class={`main-wrapper ${status}`}>
	<span class="w-medium">{message}</span>
</div>

<style lang="scss">
	.main-wrapper {
		border-top: 1px solid var(--clr-border-primary);
		padding: 0.3em 0.7em;
		display: flex;
		justify-content: center;
		align-items: center;
		text-align: center;

		span {
			font-size: 0.65em;
			line-height: 1;
		}

		&.inactive {
			background-color: var(--clr-alert-badge);
			box-shadow: inset 0px 2px 3px 0px var(--clr-shadow-primary);

			span {
				color: var(--clr-alert-main);
			}
		}

		&.active {
			background-color: var(--clr-success-badge);
			box-shadow: inset 0px 2px 3px 0px var(--clr-shadow-primary);

			span {
				color: var(--clr-success-main);
			}
		}
	}
</style>
