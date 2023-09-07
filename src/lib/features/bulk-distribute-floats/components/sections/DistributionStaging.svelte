<script lang="ts">
	import type { CertificateType } from '$lib/types/event/event-type.type';
	import type { Distribution } from '../../types/distribution.interface';
	import DistStagingElement from '../atoms/DistStagingElement.svelte';
	import { fly } from 'svelte/transition';
	import _ from 'lodash';

	export let certificateType: CertificateType;
	export let distribution: Distribution<typeof certificateType>;

	const resolveMedalTypeOrder = (medalType: string) => {
		switch (medalType) {
			case 'gold':
				return 1;
			case 'silver':
				return 2;
			case 'bronze':
				return 3;
			default:
				return 4;
		}
	};

	const deleteFromStaging = (i: number) => {
		distribution.distributionObjects.splice(i, 1);
		distribution = distribution;
	};
</script>

<div class="main-wrapper">
	<div class="dist-elements-wrapper">
		{#if distribution.distributionObjects.length > 0}
			{#each _.orderBy( distribution.distributionObjects, [(u) => resolveMedalTypeOrder(u.medal)] ) as dist, i (dist.address)}
				<DistStagingElement
					forAccount={dist.address}
					bind:medalType={dist.medal}
					on:deleteDist={() => deleteFromStaging(i)}
				/>
			{/each}
		{:else}
			<div class="request-wrapper">
				<span class="small" in:fly|local={{ y: 10, duration: 500, delay: 500 }}>
					Add the addresses you want to distribute FLOATs to.
				</span>
			</div>
		{/if}
	</div>
</div>

<style lang="scss">
	.main-wrapper {
		padding-left: var(--space-4);
		border: 1px solid var(--clr-border-primary);
		overflow: hidden;
		border-radius: var(--radius-2);
		height: 100%;

		.dist-elements-wrapper {
			height: 100%;
			display: flex;
			flex-direction: column;
			gap: 1rem;
			overflow-y: auto;
			overflow-x: hidden;
			padding-right: var(--space-5);
			padding-block: var(--space-4);

			.request-wrapper {
				height: 100%;
				width: 100%;
				display: grid;
				place-content: center;

				span {
					max-width: 26ch;
					color: var(--clr-text-off);
					text-align: center;

					&:first-child {
						margin-bottom: var(--space-4);
					}
				}
			}
		}
	}
</style>
