import type { FLOAT } from '$lib/types/float/float.interface';

export interface Group {
	id: number;
	name: string;
	description: string | null;
	user_address: string;
}

export interface GroupWithFloats extends Group {
	floats: FLOAT[];
}

export interface GroupWithFloatsIds extends Group {
	floatsIds: string[];
}
