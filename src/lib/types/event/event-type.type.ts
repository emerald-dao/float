export const EVENT_TYPES = [
	'discordMeeting',
	'twitterSpace',
	'conference',
	'productPresentation',
	'course',
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
	};
} = {
	discordMeeting: {
		certificateType: 'ticket',
		eventTypeName: 'Discord meeting'
	},
	twitterSpace: {
		certificateType: 'ticket',
		eventTypeName: 'Twitter space'
	},
	conference: {
		certificateType: 'ticket',
		eventTypeName: 'Conference'
	},
	productPresentation: {
		certificateType: 'ticket',
		eventTypeName: 'Product presentation'
	},
	course: {
		certificateType: 'certificate',
		eventTypeName: 'Course'
	},
	hackathon: {
		certificateType: 'medal',
		eventTypeName: 'Hackathon'
	},
	sportCompetition: {
		certificateType: 'medal',
		eventTypeName: 'Sport competition'
	},
	gamingCompetition: {
		certificateType: 'medal',
		eventTypeName: 'Gaming competition'
	},
	other: {
		certificateType: 'ticket',
		eventTypeName: 'Other'
	}
};
