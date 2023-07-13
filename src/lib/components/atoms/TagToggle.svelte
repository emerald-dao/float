<script lang="ts">
	import { Label } from '@emerald-dao/component-library';
	import { createEventDispatcher } from 'svelte';

	export let name: string;
	export let icon: string;

	const dispatch = createEventDispatcher();

	let value: boolean;

	$: if (value === true) {
		dispatch('selected');
	} else {
		dispatch('unselected');
	}
</script>

<div>
	<label for={name}>
		<input type="checkbox" id={name} {name} bind:checked={value} />
		<Label
			iconLeft={icon}
			state={value ? 'on' : 'off'}
			color={value ? 'tertiary' : 'transparent'}
			hasBorder={true}
		>
			<span class="w-regular small" class:on={value}>
				<slot />
			</span>
		</Label>
	</label>
</div>

<style lang="scss">
	label {
		cursor: pointer;
	}

	span {
		// color: var(--clr-text-off);
		padding: 0.2rem;

		&.on {
			color: var(--clr-tertiary-main);
		}
	}

	input {
		display: none;
	}
</style>
