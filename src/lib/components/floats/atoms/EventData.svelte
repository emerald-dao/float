<script lang="ts">
	export let align: 'left' | 'center' | 'right' = 'left';
	export let title: string;
</script>

<div class={`main-wrapper column ${align} w-medium`}>
	<span class="title off"> {title.toUpperCase()} </span>
	<slot />
</div>

<style lang="scss">
	.main-wrapper {
		.title {
			font-size: 0.55em;
			margin-bottom: 0.9%;
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
