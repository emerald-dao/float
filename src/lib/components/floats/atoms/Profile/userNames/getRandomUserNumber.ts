// This funcion should get a Flow blockchain wallet address like 0x508abfd3970f5872
// It should analyze it and return a random number between 1 and a given number x.
// The same address sholud always output the same number.
// The probability of each number should be the same.

const getRandomUserNumber = (address: string, max: number) => {
	// get the last char of the address
	const lastChar = address[address.length - 1];

	// const hash = createHash('sha256').update(address[address.length]).digest('hex');

	// Convert the hash to a decimal number
	const decimalNumber = parseInt(lastChar, 16);

	// Generate the random number between 0 and the given maximum
	const randomNumber = decimalNumber % (max + 1);

	return randomNumber;
};

export default getRandomUserNumber;
