<script lang="ts">
	import { page } from '$app/stores';
	import type { Group } from '$lib/features/groups/types/group.interface';

	export let group: Group;

	$: selected = $page.params.groupId === group.id.toString();
</script>

<a class="card" href={`/admin/groups/${group.id}`} class:selected>
	<h4 class="w-medium">{group.name}</h4>
	<p class="small">{group.description}</p>
</a>

<style lang="scss">
	a {
		text-decoration: none;
		color: var(--clr-text-main);
		padding: var(--space-6) var(--space-5);
		box-shadow: none;
		border-radius: var(--radius-2);

		&.selected {
			border-color: var(--clr-text-main);
			background: var(--clr-surface-secondary);
			box-shadow: 0px 2px 6px 0 var(--clr-shadow-primary);
		}

		&:hover {
			background: var(--clr-surface-secondary);
			box-shadow: 0px 2px 6px 0 var(--clr-shadow-primary);
		}

		h4 {
			font-size: var(--font-size-3);
			margin-bottom: var(--space-1);
		}
	}
</style>
