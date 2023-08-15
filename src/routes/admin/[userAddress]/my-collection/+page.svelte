<script lang="ts">
	import { page } from '$app/stores';
	import { goto } from '$app/navigation';
	import { onMount } from 'svelte';

	export let data;

	onMount(() => {
		if (data.floats.length > 0) {
			goto(`/admin/${$page.params.userAddress}/my-collection/${data.floats[0].eventId}`);
		}
	});
</script>

<div class="center">
	<em> You don't have any FLOAT yet </em>
</div>

<style lang="scss">
	.center {
		height: 100%;
	}
</style>
