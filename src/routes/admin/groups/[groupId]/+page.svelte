<script lang="ts">
	import { page } from '$app/stores';
	import { getContext, onMount } from 'svelte';
	import type { Group } from '../_types/group.interface';

	export let data;

	const groups: Group[] = getContext('groups');

	$: currentGroup = groups.find((g) => g.id === Number($page.params.groupId));
</script>

{#if currentGroup}
	{currentGroup.name}
{:else}
	Group not found
{/if}
