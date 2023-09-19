export interface Timelock {
	dateStart: string;
	dateEnding: string;
	type: 'timelock';
}

export interface Limited {
	capacity: string;
	type: 'limited';
}

export interface Secret {
	publicKey: string;
	type: 'secret';
}

export interface MinimumBalance {
	amount: string;
	type: 'minimumBalance';
}
