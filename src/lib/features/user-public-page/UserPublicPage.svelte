<script type="ts">
	import { EventTypeEnum } from '$lib/types/content/metadata/event-types.enum';
	import PinnedFloats from './components/PinnedFloats.svelte';
	import UserActivity from './components/UserActivity.svelte';
	import UserHeroSection from './components/UserHeroSection.svelte';
	import type { Event } from '$lib/types/event/event.interface';

	const contentList: Event[] = [
		{
			claimable: true,
			dateCreated: '06/05/2023',
			description: 'This is the first mock',
			eventId: '45363',
			extraMetadata: { key: 'string' },
			groups: ['TRY'],
			host: 'Twitter',
			image: 'string',
			name: 'FIRST EVENT',
			totalSupply: '2,306',
			transferrable: false,
			url: 'https://www.google.com.uy/',
			verifiers: [],

			// Added by Chino
			eventType: EventTypeEnum.Conference
		},
		{
			claimable: true,
			dateCreated: '06/05/2023',
			description: 'This is the second mock',
			eventId: '45363',
			extraMetadata: { key: 'string' },
			groups: ['TRY'],
			host: 'Twitter',
			image: 'string',
			name: 'SECOND EVENT',
			totalSupply: '2,306',
			transferrable: false,
			url: 'https://www.google.com.uy/',
			verifiers: [{ dateStart: '06/05/2023', dateEnding: '06/20/2023' }],

			// Added by Chino
			eventType: EventTypeEnum.Workshop
		},
		{
			claimable: true,
			dateCreated: '06/05/2023',
			description: 'This is the third mock',
			eventId: '45363',
			extraMetadata: { key: 'string' },
			groups: ['TRY'],
			host: 'Twitter',
			image: 'string',
			name: 'THIRD EVENT',
			totalSupply: '2,306',
			transferrable: false,
			url: 'https://www.google.com.uy/',
			verifiers: [{ dateStart: '06/05/2023', dateEnding: '06/20/2023' }],

			// Added by Chino
			eventType: EventTypeEnum.Online
		}
	];
</script>

<UserHeroSection />
<PinnedFloats />
<UserActivity {contentList} />
