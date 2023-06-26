export interface User {
	name: string;
	walletAddress: string;
	socialMedia?: {
		twitter?: string;
		instagram?: string;
		facebook?: string;
		tiktok?: string;
		youtube?: string;
		twitch?: string;
		discord?: string;
	};
	image: string;
	pinnedFloats: string[];
}
