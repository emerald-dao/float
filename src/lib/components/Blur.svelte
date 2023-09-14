<script lang="ts">
	export let color: 'primary' | 'secondary' | 'tertiary' = 'primary';
	export let diameter: string = '20rem';
	export let blur: string = '6rem';
	export let opacity: number = 0.2;
	export let left: string | undefined = undefined;
	export let bottom: string | undefined = undefined;
	export let top: string | undefined = undefined;
	export let right: string | undefined = undefined;
</script>

<div
	style={`width: ${diameter}; height: ${diameter}; filter: blur(${blur}); opacity: ${opacity}; left: ${left}; bottom: ${bottom}; top: ${top}; right: ${right};`}
	class={`color-${color}`}
/>

<style lang="scss">
	div {
		border-radius: 50%;
		position: absolute;
		z-index: 0;

		&.color-primary {
			background-color: var(--clr-primary-main);
		}

		&.color-secondary {
			background-color: var(--clr-secondary-main);
		}

		&.color-tertiary {
			background-color: var(--clr-tertiary-main);
		}
	}
</style>
