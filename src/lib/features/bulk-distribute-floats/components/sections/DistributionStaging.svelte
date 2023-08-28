<script lang="ts">
	import DistStagingElement from '../atoms/DistStagingElement.svelte';
	import { fly } from 'svelte/transition';

	export let distStaging: string[];

	const deleteFromStaging = (i: number) => {
		distStaging.splice(i, 1);
		distStaging = distStaging;
	};
</script>

<div class="main-wrapper">
	<div class="dist-elements-wrapper">
		{#if distStaging.length > 0}
			{#each distStaging as dist, i (`${dist}-${i}`)}
				<DistStagingElement forAccount={dist} on:deleteDist={() => deleteFromStaging(i)} />
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
