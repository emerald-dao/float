export const EVENT_TYPES = [
	'discordMeeting',
	'twitterSpace',
	'conference',
	'productPresentation',
	'course',
	'bootcamp',
	'hackathon',
	'sportCompetition',
	'gamingCompetition',
	'other'
] as const;
export const CERTIFICATE_TYPES = ['ticket', 'medal', 'certificate'] as const;

export type EventType = (typeof EVENT_TYPES)[number];
export type CertificateType = (typeof CERTIFICATE_TYPES)[number];

export const EVENT_TYPE_DETAILS: {
	[key in EventType]: {
		certificateType: CertificateType;
		eventTypeName: string;
		icon: string;
	};
} = {
	discordMeeting: {
		certificateType: 'ticket',
		eventTypeName: 'Discord meeting',
		icon: 'tabler:brand-discord'
	},
	twitterSpace: {
		certificateType: 'ticket',
		eventTypeName: 'Twitter space',
		icon: 'tabler:brand-twitter'
	},
	conference: {
		certificateType: 'ticket',
		eventTypeName: 'Conference',
		icon: 'tabler:microphone-2'
	},
	productPresentation: {
		certificateType: 'ticket',
		eventTypeName: 'Product presentation',
		icon: 'tabler:presentation'
	},
	course: {
		certificateType: 'certificate',
		eventTypeName: 'Course',
		icon: 'tabler:book'
	},
	bootcamp: {
		certificateType: 'certificate',
		eventTypeName: 'Bootcamp',
		icon: 'tabler:device-laptop'
	},
	hackathon: {
		certificateType: 'medal',
		eventTypeName: 'Hackathon',
		icon: 'tabler:code'
	},
	sportCompetition: {
		certificateType: 'medal',
		eventTypeName: 'Sport competition',
		icon: 'tabler:ball-football'
	},
	gamingCompetition: {
		certificateType: 'medal',
		eventTypeName: 'Gaming competition',
		icon: 'tabler:device-gamepad'
	},
	other: {
		certificateType: 'ticket',
		eventTypeName: 'Other',
		icon: 'tabler:ticket'
	}
};
