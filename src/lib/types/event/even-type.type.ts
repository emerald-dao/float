export const EVENT_TYPES = [
	'discordMeeting',
	'twitterSpace',
	'conference',
	'productPresentation',
	'course',
	'hackaton',
	'sportCompetition',
	'gamingCompetition',
	'other'
] as const;
export const CERTIFICATE_TYPES = ['ticket', 'medal', 'certificate'] as const;

export type EventType = (typeof EVENT_TYPES)[number];
export type CertificateType = (typeof CERTIFICATE_TYPES)[number];

type EventTypeDetail = {
	[key in EventType]: {
		certificateType: CertificateType;
		eventTypeName: string;
	};
}[EventType];

export const EVENT_TYPE_DETAILS: EventTypeDetail[] = [
	{
		discordMeeting: {
			certificateType: 'ticket',
			eventTypeName: 'Discord meeting'
		}
	},
	{
		twitterSpace: {
			certificateType: 'ticket',
			eventTypeName: 'Twitter space'
		}
	},
	{
		conference: {
			certificateType: 'ticket',
			eventTypeName: 'Conference'
		}
	},
	{
		productPresentation: {
			certificateType: 'ticket',
			eventTypeName: 'Product presentation'
		}
	},
	{
		course: {
			certificateType: 'certificate',
			eventTypeName: 'Course'
		}
	},
	{
		hackaton: {
			certificateType: 'medal',
			eventTypeName: 'Hackaton'
		}
	},
	{
		sportCompetition: {
			certificateType: 'medal',
			eventTypeName: 'Sport competition'
		}
	},
	{
		gamingCompetition: {
			certificateType: 'medal',
			eventTypeName: 'Gaming competition'
		}
	},
	{
		other: {
			certificateType: 'ticket',
			eventTypeName: 'Other'
		}
	}
].map((item) => Object.values(item)[0]);
