<script lang="ts">
	import { getMainPageFLOATs } from '$flow/actions';
	import { network } from '$flow/config';
	import Blur from '$lib/components/Blur.svelte';
	import Float from '$lib/components/floats/Float.svelte';
	import type { FLOAT } from '$lib/types/float/float.interface';
	import { multiplyArray } from '$lib/utilities/multiplyArray';
	import SectionHeading from './atoms/SectionHeading.svelte';

	async function fetchFLOATs(): Promise<FLOAT[]> {
		const floats =
			network === 'mainnet'
				? [
						{
							key: '0x99bd48c8036e2876',
							value: [
								'187900113',
								'187900113',
								'405872636',
								'228913853',
								'234035601',
								'241506344',
								'228534369',
								'269981325',
								'193020626',
								'185940653',
								'584134932',
								'287540237'
							]
						}
				  ]
				: network === 'testnet' 
				? [
					{
							key: '0xd7f69a06f10eae0e',
							value: [
								'173212687',
								'173205675',
								'173205595',
								'173143165'
							]
						}
				] : [];
		return await getMainPageFLOATs(floats);
	}
</script>

{#await fetchFLOATs() then FLOATS}
	{#if FLOATS.length > 0}
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
						<Float {float} minWidth="400px" />
					</div>
				{/each}
			</div>
		</section>
	{/if}
{/await}

<style lang="scss">
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
