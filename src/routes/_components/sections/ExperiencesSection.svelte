<script lang="ts">
	import Blur from '$lib/components/Blur.svelte';
	import FloatTicket from '$lib/components/floats/FloatTicket.svelte';
	import { multiplyArray } from '$lib/utilities/multiplyArray';
	import SectionHeading from './atoms/SectionHeading.svelte';

	const FLOATS = [
		{
			title: 'The Emerald Conference',
			number: 1242343,
			attendantAddress: '0x1234567890',
			eventType: 'Conference',
			eventOrganizer: 'Emerald DAO'
		},
		{
			title: 'The Emerald Conference',
			number: 1242343,
			attendantAddress: '0x1234567890',
			eventType: 'Conference',
			eventOrganizer: 'Emerald DAO'
		},
		{
			title: 'The Emerald Conference',
			number: 1242343,
			attendantAddress: '0x1234567890',
			eventType: 'Conference',
			eventOrganizer: 'Emerald DAO'
		},
		{
			title: 'The Emerald Conference',
			number: 1242343,
			attendantAddress: '0x1234567890',
			eventType: 'Conference',
			eventOrganizer: 'Emerald DAO'
		},
		{
			title: 'The Emerald Conference',
			number: 1242343,
			attendantAddress: '0x1234567890',
			eventType: 'Conference',
			eventOrganizer: 'Emerald DAO'
		},
		{
			title: 'The Emerald Conference',
			number: 1242343,
			attendantAddress: '0x1234567890',
			eventType: 'Conference',
			eventOrganizer: 'Emerald DAO'
		},
		{
			title: 'The Emerald Conference',
			number: 1242343,
			attendantAddress: '0x1234567890',
			eventType: 'Conference',
			eventOrganizer: 'Emerald DAO'
		},
		{
			title: 'The Emerald Conference',
			number: 1242343,
			attendantAddress: '0x1234567890',
			eventType: 'Conference',
			eventOrganizer: 'Emerald DAO'
		},
		{
			title: 'The Emerald Conference',
			number: 1242343,
			attendantAddress: '0x1234567890',
			eventType: 'Conference',
			eventOrganizer: 'Emerald DAO'
		},
		{
			title: 'The Emerald Conference',
			number: 1242343,
			attendantAddress: '0x1234567890',
			eventType: 'Conference',
			eventOrganizer: 'Emerald DAO'
		},
		{
			title: 'The Emerald Conference',
			number: 1242343,
			attendantAddress: '0x1234567890',
			eventType: 'Conference',
			eventOrganizer: 'Emerald DAO'
		},
		{
			title: 'The Emerald Conference',
			number: 1242343,
			attendantAddress: '0x1234567890',
			eventType: 'Conference',
			eventOrganizer: 'Emerald DAO'
		},
		{
			title: 'The Emerald Conference',
			number: 1242343,
			attendantAddress: '0x1234567890',
			eventType: 'Conference',
			eventOrganizer: 'Emerald DAO'
		}
	];
</script>

<section class="column-11">
	<Blur color="tertiary" right="30%" top="10%" />
	<Blur left="30%" top="20%" />
	<SectionHeading
		title="Life is about experiences. Collect them!"
		description="Create your personal collection of all the events you assisted."
	/>
	<div class="floats-wrapper">
		{#each multiplyArray(FLOATS, 30) as float, i}
			<div class="float-{i}">
				<FloatTicket
					title={float.title}
					floatNumber={float.number}
					attendantAddress={float.attendantAddress}
					eventType={float.eventType}
					eventOrganizer={float.eventOrganizer}
				/>
			</div>
		{/each}
	</div>
</section>

<style type="scss">
	section {
		overflow-x: hidden;
		position: relative;

		.floats-wrapper {
			display: grid;
			grid-auto-flow: column dense; /* column flow with "dense" to fill all the cells */
			grid-template-rows: 1fr 1fr; /* 2 rows */
			gap: var(--space-10);
			justify-content: center;
			width: 1px;

			[class^='float-']:nth-child(even) {
				animation: moving 1000s infinite;
				animation-timing-function: linear;
			}

			[class^='float-']:nth-child(odd) {
				animation: moving2 1000s infinite;
				animation-timing-function: linear;
			}

			@keyframes moving {
				0% {
					transform: translate(0);
				}
				100% {
					transform: translate(10000%);
				}
			}

			@keyframes moving2 {
				0% {
					transform: translate(0);
				}
				100% {
					transform: translate(-10000%);
				}
			}
		}
	}
</style>
