export const unixTimestampToFormattedDate = (
	timestamp: string,
	format: 'year' | 'month' | 'date' = 'date'
): string => {
	const seconds = Math.floor(Number(timestamp));
	const fractionalSeconds = Math.round((Number(timestamp) % 1) * 1000);

	const date = new Date(seconds * 1000 + fractionalSeconds);

	const month = date.getMonth() + 1;
	const year = date.getFullYear();

	if (format === 'year') {
		return year.toString();
	} else if (format === 'month') {
		const formattedMonth = date.toLocaleString('en-US', { month: 'short' });
		return formattedMonth;
	} else {
		const day = date.getDate();
		const formattedDate = `${month.toString().padStart(2, '0')}/${day
			.toString()
			.padStart(2, '0')}/${year}`;
		return formattedDate;
	}
};
