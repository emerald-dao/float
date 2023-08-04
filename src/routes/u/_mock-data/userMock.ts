import type { User } from '$lib/types/user/user.interface';

const userMock: User = {
	name: 'John Doe',
	walletAddress: '0x1234567890',
	socialMedia: {
		twitter: 'https://twitter.com/JohnDoe',
		instagram: 'https://instagram.com/JohnDoe',
		facebook: 'https://facebook.com/JohnDoe'
	},
	image: 'https://i.pravatar.cc/300',
	pinnedFloats: ['1', '2']
};

export default userMock;
