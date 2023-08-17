import {
	TOTAL_FLOATS_BADGE,
	USER_EVENT_BADGE,
	USER_FLOAT_BADGES,
	USER_OVERALL_BADGE
} from '../userBadges';
import type { FLOAT } from '$lib/types/float/float.interface';
import type { Event } from '$lib/types/event/event.interface';

export const getUserFloatsBadges = (userFloats: FLOAT[]): number[] => {
	const levels: number[] = [];

	for (let i = 0; i < USER_FLOAT_BADGES.length; i++) {
		const levelFloatNumber = USER_FLOAT_BADGES[i].rule(userFloats);

		levels.push(levelFloatNumber);
	}

	return levels;
};

export const getUserAllFloatsBadge = (userFloats: FLOAT[]): number => {
	const level = TOTAL_FLOATS_BADGE.rule(userFloats);

	return level;
};

export const getUserEventBadge = (userEvents: Event[]): number => {
	const level = USER_EVENT_BADGE.rule(userEvents);

	return level;
};

export const getUserOverallLevel = (totalFloats: number, totalEvents: number): number => {
	const userOverallLevel = USER_OVERALL_BADGE.rule(totalFloats, totalEvents);

	return userOverallLevel;
};
