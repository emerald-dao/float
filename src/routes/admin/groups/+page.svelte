<script lang="ts">
	import { goto } from '$app/navigation';
	import { getContext, onMount } from 'svelte';
	import type { Writable } from 'svelte/store';
	import type { Group } from '$lib/features/groups/types/group.interface';

	let groups: Writable<Group[]> = getContext('groups');

	onMount(() => {
		if ($groups.length > 0) {
			goto(`/admin/groups/${$groups[0].id}`);
		}
	});
</script>

<div class="center" />

<style lang="scss">
	.center {
		height: 100%;
	}
</style>
