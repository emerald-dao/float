<script lang="ts">
	export let align: 'left' | 'center' | 'right' = 'left';
	export let title: string;
</script>

<div class={`main-wrapper column ${align} w-medium`}>
	<span class="organized-by off"> {title.toUpperCase()} </span>
	<slot />
</div>

<style lang="scss">
	.main-wrapper {
		// background-color: var(--clr-background-secondary);
		// border: 1px solid var(--clr-neutral-badge);
		// padding: 2% 3%;
		// border-radius: 0.5em;
		// width: 100%;

		.organized-by {
			font-size: 0.6em;
			margin-bottom: 1.5%;
			letter-spacing: 0.1em;
		}

		&.left {
			align-items: flex-start;
			text-align: left;
		}

		&.center {
			align-items: center;
			text-align: center;
		}

		&.right {
			align-items: flex-end;
			text-align: right;
		}
	}

	.off {
		color: var(--clr-text-off);
		opacity: 0.7;
	}
</style>
