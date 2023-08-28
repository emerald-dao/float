export interface Timelock {
	dateStart: string;
	dateEnding: string;
}

export interface Limited {
	capacity: string;
}

export interface Secret {
	publicKey: string;
}

export interface MinimumBalance {
	amount: string;
}
