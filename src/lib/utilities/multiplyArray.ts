export const multiplyArray = <T>(arr: T[], numTimes: number) => {
	// Check if the numTimes is valid
	if (numTimes <= 0) {
		return arr;
	}

	// Create a new array to store the multiplied elements
	const result = [];

	// Loop through the array and multiply it for the given number of times
	for (let i = 0; i < numTimes; i++) {
		result.push(...arr);
	}

	return result;
};
