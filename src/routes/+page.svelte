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
	import { supabase } from '$lib/supabase/supabaseClient';

	supabase
		.from('users')
		.select()
		.then((res) => {
			console.log(res.data);
		});
</script>

<HeroSection />
<StatsSection bordersColor="var(--clr-border-primary)" />
<EventTypesSection />
<ExperiencesSection />
<HowItWorksSection />
<TechnicalDetailsSection />
<MintAFloatSection />
