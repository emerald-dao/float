<script lang="ts">
	import type { FLOAT } from '$lib/types/float/float.interface';
	import { page } from '$app/stores';
	import FloatCardContent from './FloatCardContent.svelte';
	import { createEventDispatcher } from 'svelte';

	export let float: FLOAT;
	export let hasLink = true;
	export let selected = false;
	export let clickable = false;

	const dispatch = createEventDispatcher();

	$: if ($page.params.id) {
		selected = float.eventId === $page.params.id;
	}
</script>

{#if hasLink}
	<a
		class="info-wrapper {float.eventId === $page.params.id ? 'selected' : ''}"
		class:selected={float.eventId === $page.params.id}
		href={`/admin/my-collection/${float.eventId}`}
	>
		<FloatCardContent {float} {selected} clickable={true} />
	</a>
{:else}
	<div on:click={() => dispatch('floatClicked', float.id)} class:cursor-pointer={clickable}>
		<FloatCardContent {float} {selected} {clickable} />
	</div>
{/if}

<style lang="scss">
	a {
		text-decoration: none;
		color: unset;
		transition: 300ms ease-in-out;
	}

	a,
	div {
		width: 100%;
	}

	.cursor-pointer {
		cursor: pointer;
	}
</style>
