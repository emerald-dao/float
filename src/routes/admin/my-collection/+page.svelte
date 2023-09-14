<script lang="ts">
	import { goto } from '$app/navigation';
	import { getContext, onMount } from 'svelte';
	import type { FLOAT } from '$lib/types/float/float.interface';
	import type { Writable } from 'svelte/store';

	let floats: Writable<FLOAT[]> = getContext('floats');

	onMount(() => {
		if ($floats.length > 0) {
			goto(`/admin/my-collection/${$floats[0].eventId}`);
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
