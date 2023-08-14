import { USER_EVENT_BADGES, USER_FLOAT_BADGES, USER_OVERALL_BADGE } from '../userBadges';
import type { FLOAT } from '$lib/types/float/float.interface';
import type { Event } from '$lib/types/event/event.interface';

export const getUserFloatsBadges = (userFloats: FLOAT[]): number[] => {
	const userFloatsLevels: number[] = [];

	for (let i = 0; i < USER_FLOAT_BADGES.length; i++) {
		const levelFloatNumber = USER_FLOAT_BADGES[i].rule(userFloats);

		userFloatsLevels.push(levelFloatNumber);
	}

	return userFloatsLevels;
};

export const getUserEventsBadges = (userEvents: Event[]): number[] => {
	const userEventsLevels: number[] = [];

	for (let i = 0; i < USER_EVENT_BADGES.length; i++) {
		const levelEventNumber = USER_EVENT_BADGES[i].rule(userEvents);

		userEventsLevels.push(levelEventNumber);
	}

	return userEventsLevels;
};

export const getUserOverallLevel = (totalFloats: number, totalEvents: number): number => {
	const userOverallLevel = USER_OVERALL_BADGE[0].rule(totalFloats, totalEvents);

	return userOverallLevel;
};
