<script lang="ts">
	import { StatsSection } from '@emerald-dao/component-library';
	import {
		EventTypesSection,
		ExperiencesSection,
		HeroSection,
		HowItWorksSection,
		MintAFloatSection,
		TechnicalDetailsSection
	} from './_components/sections';
	import { getStats } from '$flow/actions';
</script>

<HeroSection />
{#await getStats() then stats}
	<StatsSection
		bordersColor="var(--clr-border-primary)"
		data={{
			data1: { title: 'students', stat: parseInt(stats.floatTotalSupply).toLocaleString() },
			data2: { title: 'hours of content', stat: parseInt(stats.eventsCreated).toLocaleString() }
		}}
	/>
{/await}
<EventTypesSection />
<ExperiencesSection />
<HowItWorksSection />
<TechnicalDetailsSection />
<MintAFloatSection />
