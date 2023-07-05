export const unixTimeStampToDate = (timestamp: string): string => {
	const seconds = Math.floor(Number(timestamp));
	const fractionalSeconds = Math.round((Number(timestamp) % 1) * 1000); // Assuming decimal part represents fractional seconds

	const date = new Date(seconds * 1000 + fractionalSeconds); // Add fractional seconds to the timestamp

	const month = date.getMonth() + 1;
	const day = date.getDate();
	const year = date.getFullYear();

	const formattedDate = `${month.toString().padStart(2, '0')}/${day
		.toString()
		.padStart(2, '0')}/${year}`;

	return formattedDate;
};
