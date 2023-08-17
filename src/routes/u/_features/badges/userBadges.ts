import type { Badge } from './badges.interface';
import type { FLOAT } from '$lib/types/float/float.interface';
import type { EventType } from '$lib/types/event/even-type.type';

const eventTypeBadgesRule = (floatsList: FLOAT[], eventType: EventType) => {
	const eachEventTypeFloatsCount = floatsList.filter(
		(float) => float.eventType === eventType
	).length;

	if (eachEventTypeFloatsCount >= 50) return 4;
	if (eachEventTypeFloatsCount >= 15) return 3;
	if (eachEventTypeFloatsCount >= 5) return 2;
	if (eachEventTypeFloatsCount >= 1) return 1;
	return 0;
};

export const TOTAL_FLOATS_BADGE: Badge = {
	name: 'Float Tycoon',
	levels: [
		{
			name: '🌱 Emerging Tycoon',
			image: '/badges/float-tycoon/level-1.png',
			description:
				"Your holdings are starting to grow. You're on your way to becoming a Float tycoon.",
			goal: 'Hold 5 total FLOATs'
		},
		{
			name: '💼 Flourishing Tycoon',
			image: '/badges/float-tycoon/level-2.png',
			description: 'Your portfolio is expanding! You`re well on your way to Float tycoon status.',
			goal: 'Hold 20 total FLOATs'
		},
		{
			name: '🏦 Prosperous Tycoon',
			image: '/badges/float-tycoon/level-3.png',
			description: 'Your Float empire is thriving! Your holdings are impressive.',
			goal: 'Hold 50 total FLOATs'
		},
		{
			name: '🏅 Wealthy Mogul',
			image: '/badges/float-tycoon/level-4.png',
			description: "You've reached mogul status! Holding 100 total FLOATs is a remarkable feat.",
			goal: 'Hold 100 total FLOATs'
		},
		{
			name: '🌟 Float Magnate',
			image: '/badges/float-tycoon/level-5.png',
			description:
				"You're a true Float magnate! Your holdings of 500 total FLOATs are awe-inspiring.",
			goal: 'Hold 500 total FLOATs'
		}
	],
	rule: (floats) => {
		const totalAmountCount = floats.length;
		if (totalAmountCount >= 500) return 5;
		if (totalAmountCount >= 100) return 4;
		if (totalAmountCount >= 50) return 3;
		if (totalAmountCount >= 20) return 2;
		if (totalAmountCount >= 5) return 1;
		return 0;
	}
};

export const USER_FLOAT_BADGES: Badge[] = [
	{
		name: 'Other Enthusiast',
		levels: [
			{
				name: '🌌 Newcomer',
				image: '/badges/each-event-type-floats/level-1.png',
				description:
					"You've attended your first 'Other' event on FLOAT. Welcome to the diverse world of FLOATs!",
				goal: 'Hold 1 FLOAT of "Other" type'
			},
			{
				name: '🚀 Explorer',
				image: '/badges/each-event-type-floats/level-2.png',
				description:
					"Your adventurous spirit leads you to different 'Other' events. Keep discovering!",
				goal: 'Hold 5 FLOATs of "Other" type'
			},
			{
				name: '🌟 Versatile Voyager',
				image: '/badges/each-event-type-floats/level-3.png',
				description:
					"You embrace the variety of 'Other' events, making your journey exciting and diverse.",
				goal: 'Hold 15 FLOATs of "Other" type'
			},
			{
				name: '🌈 Master Enthusiast',
				image: '/badges/each-event-type-floats/level-4.png',
				description:
					"Your passion for 'Other' events knows no bounds. You're an embodiment of FLOAT diversity.",
				goal: 'Hold 50 FLOATs of "Other" type'
			}
		],
		rule: (floats) => eventTypeBadgesRule(floats as FLOAT[], 'other')
	},
	{
		name: 'Discord Dynamo',
		levels: [
			{
				name: '🎮 Novice Conqueror',
				image: '/badges/each-event-type-floats/level-1.png',
				description:
					"You've attended your first Discord meeting on FLOAT. Keep exploring the gaming community!",
				goal: 'Hold 1 FLOAT of Discord meeting type'
			},
			{
				name: '🎙️ Adept Navigator',
				image: '/badges/each-event-type-floats/level-2.png',
				description:
					"Your participation in Discord meetings is commendable. You're making your presence known.",
				goal: 'Hold 5 FLOATs of Discord meeting type'
			},
			{
				name: '💬 Master Collaborator',
				image: '/badges/each-event-type-floats/level-3.png',
				description:
					"Your involvement in Discord meetings is recognized by others. You're an active contributor.",
				goal: 'Hold 15 FLOATs of Discord meeting type'
			},
			{
				name: '🌟 Discord Dynamo',
				image: '/badges/each-event-type-floats/level-4.png',
				description:
					"You're a powerhouse in Discord meetings! Your contributions are influential and impactful.",
				goal: 'Hold 50 FLOATs of Discord meeting type'
			}
		],
		rule: (floats) => eventTypeBadgesRule(floats as FLOAT[], 'discordMeeting')
	},
	{
		name: 'Twitter Titan',
		levels: [
			{
				name: '🐦 Novice Tweeter',
				image: '/badges/each-event-type-floats/level-1.png',
				description:
					"You've attended your first Twitter space on FLOAT. Keep engaging with the community!",
				goal: 'Hold 1 FLOAT of Twitter space type'
			},
			{
				name: '🗣️ Active Participant',
				image: '/badges/each-event-type-floats/level-2.png',
				description:
					'Your active presence in Twitter spaces is appreciated. You contribute meaningfully.',
				goal: 'Hold 5 FLOATs of Twitter space type'
			},
			{
				name: '📣 Social Influencer',
				image: '/badges/each-event-type-floats/level-3.png',
				description:
					'Your engagements in Twitter spaces are impactful. Others look up to your contributions.',
				goal: 'Hold 15 FLOATs of Twitter space type'
			},
			{
				name: '🌟 Twitter Titan',
				image: '/badges/each-event-type-floats/level-4.png',
				description: "You're a Twitter legend! Your presence in spaces creates a positive buzz.",
				goal: 'Hold 50 FLOATs of Twitter space type'
			}
		],
		rule: (floats) => eventTypeBadgesRule(floats as FLOAT[], 'twitterSpace')
	},
	{
		name: 'Conference Captain',
		levels: [
			{
				name: '🎤 Confident Speaker',
				image: '/badges/each-event-type-floats/level-1.png',
				description:
					"You've attended your first conference on FLOAT. Embrace the world of knowledge-sharing!",
				goal: 'Hold 1 FLOAT of Conference type'
			},
			{
				name: '📢 Engaging Presenter',
				image: '/badges/each-event-type-floats/level-2.png',
				description:
					'Your presentation skills make an impact at conferences. Keep captivating the audience!',
				goal: 'Hold 5 FLOATs of Conference type'
			},
			{
				name: '💼 Expert Moderator',
				image: '/badges/each-event-type-floats/level-3.png',
				description:
					'Your expertise shines as a conference moderator. You keep discussions flowing smoothly.',
				goal: 'Hold 15 FLOATs of Conference type'
			},
			{
				name: '🌟 Conference Captain',
				image: '/badges/each-event-type-floats/level-4.png',
				description:
					"You're a master of conferences! Your contributions elevate the knowledge-sharing experience.",
				goal: 'Hold 50 FLOATs of Conference type'
			}
		],
		rule: (floats) => eventTypeBadgesRule(floats as FLOAT[], 'conference')
	},
	{
		name: 'Product Presentation Pro',
		levels: [
			{
				name: '🚀 Product Enthusiast',
				image: '/badges/each-event-type-floats/level-1.png',
				description:
					"You've attended your first product presentation on FLOAT. Discover exciting innovations!",
				goal: 'Hold 1 FLOAT of Product presentation type'
			},
			{
				name: '🌟 Product Advocate',
				image: '/badges/each-event-type-floats/level-2.png',
				description: "You're a vocal supporter of remarkable products. Your feedback is valued.",
				goal: 'Hold 5 FLOATs of Product presentation type'
			},
			{
				name: '🎉 Product Ambassador',
				image: '/badges/each-event-type-floats/level-3.png',
				description:
					"Your enthusiasm for product presentations is infectious. You're a brand ambassador.",
				goal: 'Hold 15 FLOATs of Product presentation type'
			},
			{
				name: '🌟 Product Presentation Pro',
				image: '/badges/each-event-type-floats/level-4.png',
				description:
					"You're a pro in product presentations! Your insights help shape innovative products.",
				goal: 'Hold 50 FLOATs of Product presentation type'
			}
		],
		rule: (floats) => eventTypeBadgesRule(floats as FLOAT[], 'productPresentation')
	},
	{
		name: 'Course Conqueror',
		levels: [
			{
				name: '🎓 Knowledge Seeker',
				image: '/badges/each-event-type-floats/level-1.png',
				description:
					"You've attended your first course on FLOAT. Expand your horizons through learning!",
				goal: 'Hold 1 FLOAT of Course type'
			},
			{
				name: '📚 Curious Scholar',
				image: '/badges/each-event-type-floats/level-2.png',
				description:
					'Your thirst for knowledge is evident. You actively engage in various courses.',
				goal: 'Hold 5 FLOATs of Course type'
			},
			{
				name: '🏆 Master Student',
				image: '/badges/each-event-type-floats/level-3.png',
				description:
					"Your dedication to learning is commendable. You're a master of various subjects.",
				goal: 'Hold 15 FLOATs of Course type'
			},
			{
				name: '🌟 Course Conqueror',
				image: '/badges/each-event-type-floats/level-4.png',
				description:
					"You've conquered the world of courses! Your expertise shines through your accomplishments.",
				goal: 'Hold 50 FLOATs of Course type'
			}
		],
		rule: (floats) => eventTypeBadgesRule(floats as FLOAT[], 'course')
	},
	{
		name: 'Hackathon Hero',
		levels: [
			{
				name: '💻 Code Novice',
				image: '/badges/each-event-type-floats/level-1.png',
				description: "You've attended your first hackathon on FLOAT. Unlock your coding potential!",
				goal: 'Hold 1 FLOAT of Hackaton type'
			},
			{
				name: '🚀 Coding Enthusiast',
				image: '/badges/each-event-type-floats/level-2.png',
				description:
					"Your passion for coding is evident. You're eager to take on hackathon challenges.",
				goal: 'Hold 5 FLOATs of Hackaton type'
			},
			{
				name: '🎖️ Hackathon Champion',
				image: '/badges/each-event-type-floats/level-3.png',
				description:
					"You're a hackathon champion! Your coding skills set you apart in competitions.",
				goal: 'Hold 15 FLOATs of Hackaton type'
			},
			{
				name: '🌟 Hackathon Hero',
				image: '/badges/each-event-type-floats/level-4.png',
				description: "You're a coding hero, leading your team to victory in intense hackathons.",
				goal: 'Hold 50 FLOATs of Hackaton type'
			}
		],
		rule: (floats) => eventTypeBadgesRule(floats as FLOAT[], 'hackathon')
	},
	{
		name: 'Sport Superstar',
		levels: [
			{
				name: '🏅 Sport Enthusiast',
				image: '/badges/each-event-type-floats/level-1.png',
				description:
					"You've attended your first sport competition on FLOAT. Embrace the thrill of sports!",
				goal: 'Hold 1 FLOAT of Sport competition type'
			},
			{
				name: '🚴‍♂️ Athletic Competitor',
				image: '/badges/each-event-type-floats/level-2.png',
				description:
					'Your passion for sports is evident. You actively participate in various competitions.',
				goal: 'Hold 5 FLOATs of Sport competition type'
			},
			{
				name: '🏆 Sporting Champion',
				image: '/badges/each-event-type-floats/level-3.png',
				description:
					"You're a sporting champion! Your victories are celebrated in the sports community.",
				goal: 'Hold 15 FLOATs of Sport competition type'
			},
			{
				name: '🌟 Sport Superstar',
				image: '/badges/each-event-type-floats/level-4.png',
				description:
					"You're a sport superstar, admired for your exceptional performance in sports.",
				goal: 'Hold 50 FLOATs of Sport competition type'
			}
		],
		rule: (floats) => eventTypeBadgesRule(floats as FLOAT[], 'sportCompetition')
	},
	{
		name: 'Gaming Gladiator',
		levels: [
			{
				name: '🎮 Gaming Rookie',
				image: '/badges/each-event-type-floats/level-1.png',
				description:
					"You've attended your first gaming competition on FLOAT. Enter the realm of gaming champions!",
				goal: 'Hold 1 FLOAT of Gaming competition type'
			},
			{
				name: '🏆 Gaming Enthusiast',
				image: '/badges/each-event-type-floats/level-2.png',
				description: 'Your passion for gaming competitions is evident. Keep honing your skills!',
				goal: 'Hold 5 FLOATs of Gaming competition type'
			},
			{
				name: '🎖️ Gaming Champion',
				image: '/badges/each-event-type-floats/level-3.png',
				description:
					"You're a champion gamer! Your victories are celebrated in the gaming community.",
				goal: 'Hold 15 FLOATs of Gaming competition type'
			},
			{
				name: '🌟 Gaming Gladiator',
				image: '/badges/each-event-type-floats/level-4.png',
				description: "You're a gaming gladiator, feared and respected in gaming competitions.",
				goal: 'Hold 50 FLOATs of Gaming competition type'
			}
		],
		rule: (floats) => eventTypeBadgesRule(floats as FLOAT[], 'gamingCompetition')
	}
];

export const USER_EVENT_BADGE: Badge = {
	name: 'Event Maestro',
	levels: [
		{
			name: '🌱 Novice Organizer',
			image: '/badges/event-maestro/level-1.png',
			description:
				"You've successfully created your first event on FLOAT. Keep the momentum going!",
			goal: 'Create 1 event on FLOAT.'
		},
		{
			name: '🔧 Skillful Coordinator',
			image: '/badges/event-maestro/level-2.png',
			description:
				'Your event-organizing skills are evident. Three successful events under your belt!',
			goal: 'Create 3 event on FLOAT.'
		},
		{
			name: '🚀 Event Virtuoso',
			image: '/badges/event-maestro/level-3.png',
			description: 'You`re a virtuoso in event creation! Double-digit events showcase your talent.',
			goal: 'Create 10 event on FLOAT.'
		},
		{
			name: '🎇 Master Orchestrator',
			image: '/badges/event-maestro/level-4.png',
			description: "Your event prowess is unmatched. You've orchestrated 20 successful events!",
			goal: 'Create 20 event on FLOAT.'
		}
	],
	rule: (events) => {
		const eventsCreatedCount = events.length;
		if (eventsCreatedCount >= 20) return 4;
		if (eventsCreatedCount >= 10) return 3;
		if (eventsCreatedCount >= 3) return 2;
		if (eventsCreatedCount >= 1) return 1;
		return 0;
	}
};

export const USER_OVERALL_BADGE: Badge = {
	name: 'Achievement Ace',
	levels: [
		{
			name: '🌟 Apprentice',
			image: '/badges/overall/level-1.png',
			description: "You're an aspiring achiever. Your journey to greatness has begun!",
			goal: 'Add 6 between the amount of FLOATs and Events'
		},
		{
			name: '🔥 Progressing Pro',
			image: '/badges/overall/level-2.png',
			description: 'Your achievements are gaining momentum. Your hard work is paying off.',
			goal: 'Add 23 between the amount of FLOATs and Events'
		},
		{
			name: '🚀 Rising Star',
			image: '/badges/overall/level-3.png',
			description:
				"You're shining brightly in the realm of accomplishments. Your dedication is admirable.",
			goal: 'Add 60 between the amount of FLOATs and Events'
		},
		{
			name: '💫 Distinguished Expert',
			image: '/badges/overall/level-4.png',
			description: 'Your excellence is recognized by all. Your achievements are extraordinary.',
			goal: 'Add 120 between the amount of FLOATs and Events'
		},
		{
			name: '🌟 Achievement Ace',
			image: '/badges/overall/level-5.png',
			description:
				"You're the epitome of achievement! Your contributions have left an indelible mark.",
			goal: 'Add 550 between the amount of FLOATs and Events'
		}
	],
	rule: (floats, events) => {
		if (typeof floats === 'number' && typeof events === 'number') {
			const totalFloatsAndEvents = floats + events;
			if (totalFloatsAndEvents >= 550) return 5;
			if (totalFloatsAndEvents >= 120) return 4;
			if (totalFloatsAndEvents >= 60) return 3;
			if (totalFloatsAndEvents >= 23) return 2;
			if (totalFloatsAndEvents >= 6) return 1;
			return 0;
		} else {
			return 0;
		}
	}
};
