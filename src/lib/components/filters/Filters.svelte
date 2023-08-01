<script lang="ts">
	import TagToggle from '$lib/components/atoms/TagToggle.svelte';
	import type { Filter, FilterSlugs } from '$lib/types/content/filters/filter.interface';

	export let filters: Filter[];

	const addToFilterBucket = (bucket: number, slug: FilterSlugs) => {
		filters[bucket].filterBucket.push(slug);
		return filters[bucket].filterBucket;
	};

	const deleteFromFilterBucket = (bucket: number, slug: FilterSlugs) => {
		const index = filters[bucket].filterBucket.indexOf(slug);
		if (index > -1) {
			filters[bucket].filterBucket.splice(index, 1);
		}
		return filters[bucket].filterBucket;
	};
</script>

{#each filters as filter, i}
	<div>
		<div class="tags-wrapper">
			{#each filter.filterElement as element}
				<TagToggle
					icon={element.icon}
					name={element.slug}
					on:selected={() => (filters[i].filterBucket = addToFilterBucket(i, element.slug))}
					on:unselected={() => (filters[i].filterBucket = deleteFromFilterBucket(i, element.slug))}
				>
					{element.text}
				</TagToggle>
			{/each}
		</div>
	</div>
{/each}

<style lang="scss">
	.tags-wrapper {
		display: flex;
		flex-direction: row;
		gap: var(--space-2);
		flex-wrap: wrap;
	}
</style>
