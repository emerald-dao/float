<script lang="ts">
	import { page } from '$app/stores';
	import { goto } from '$app/navigation';
	import { onMount } from 'svelte';

	export let data;

	onMount(() => {
		if (data.groups.length > 0) {
			goto(`/admin/${$page.params.userAddress}/groups/${data.groups[0].id}`);
		} else {
			goto(`/admin/${$page.params.userAddress}/groups/new-group`);
		}
	});
</script>

<div class="center">
	<em> You don't have any group yet </em>
</div>

<style lang="scss">
	.center {
		height: 100%;
	}
</style>
