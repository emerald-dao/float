<script lang="ts">
	import Blur from '$lib/components/Blur.svelte';
	import Float from '$lib/components/floats/Float.svelte';
	import homeFloatTickets from '$lib/config/homeFloatTickets';
	import type { FLOAT } from '$lib/types/float/float.interface';
	import { Button } from '@emerald-dao/component-library';
	import { onMount } from 'svelte';

	const getRandomFLOAT = async (floats: FLOAT[]) => {
		const randomIndex = Math.floor(Math.random() * floats.length);
		return floats[randomIndex];
	};

	let randomFLOAT: FLOAT | null = null;

	onMount(async () => {
		randomFLOAT = await getRandomFLOAT(homeFloatTickets);
	});
</script>

<section class="container-small center column-12">
	<Blur color="tertiary" right="0" top="30%" />
	<Blur left="0" bottom="20%" />
	<div class="column-1 center">
		<h1 class="w-bold">Reward Attendance</h1>
		<p class="h5">
			Create a unique and valuable experience for event attendees, while increasing engagement and
			trust for event creators.
		</p>
	</div>
	{#if randomFLOAT}
		<Float float={randomFLOAT} />
	{/if}
	<div class="column-2 center">
		<Button color="primary" size="large" width="extended" href="/event-generator"
			>Create an Event - it's free!</Button
		>
		<div class="column center">
			<span class="xsmall">FLOAT is 100% free</span>
			<span class="xsmall">We only charge a tiny percentage on payed FLOATs. </span>
		</div>
	</div>
</section>

<style lang="scss">
	section {
		position: relative;

		h1 {
			text-align: center;
		}

		p.h5 {
			text-align: center;
			color: var(--clr-text-main);
			max-width: 40ch;
		}
	}
</style>
