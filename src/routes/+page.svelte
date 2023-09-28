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
			data1: { title: 'FLOATs Claimed', stat: parseInt(stats.floatTotalSupply).toLocaleString() },
			data2: { title: 'Events Created', stat: parseInt(stats.eventsCreated).toLocaleString() }
		}}
	/>
{/await}
<EventTypesSection />
<div class="hide-in-mobile">
	<ExperiencesSection />
</div>
<HowItWorksSection />
<TechnicalDetailsSection />
<MintAFloatSection />

<style lang="scss">
	.hide-in-mobile {
		display: none;
		@include mq(small) {
			display: block;
		}
	}
</style>
