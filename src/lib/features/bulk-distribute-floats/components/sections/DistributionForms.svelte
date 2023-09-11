<script lang="ts">
	import type { CertificateType } from '$lib/types/event/event-type.type';
	import { fly } from 'svelte/transition';
	import { Tabs, Tab, TabList, TabPanel } from '@emerald-dao/component-library';
	import type { Distribution, DistributionElement } from '../../types/distribution.interface';
	import ManualDistribution from './atoms/ManualDistribution.svelte';
	import CsvDistribution from './atoms/CsvDistribution.svelte';

	export let addressInputValue: string;
	export let certificateType: CertificateType;
	export let csvDist: DistributionElement<typeof certificateType>[];
	export let addToStagingFromCsv: () => void;
	export let addToStagingFromInput: () => void;
	export let distribution: Distribution<typeof certificateType>;
	export let csvFiles: File[] = [];
</script>

<div transition:fly|local={{ duration: 200, y: 30 }}>
	<Tabs>
		<TabList>
			<Tab>
				<span class="xsmall"> Manual distribution </span>
			</Tab>
			<Tab><span class="xsmall">Bulk distribution (CSV)</span></Tab>
		</TabList>
		<TabPanel>
			<ManualDistribution
				bind:addressInputValue
				bind:distribution
				{certificateType}
				{addToStagingFromInput}
			/>
		</TabPanel>
		<TabPanel>
			<CsvDistribution bind:csvDist bind:csvFiles {certificateType} {addToStagingFromCsv} />
		</TabPanel>
	</Tabs>
</div>
