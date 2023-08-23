const validateSecretCode = async (eventId: string, eventHost: string, secretCode: string, claimee: string) => {
	const response = await fetch(`/api/validate-claim-secret/${eventHost}/${eventId}/${secretCode}/${claimee}`);
	const result = await response.json();
	return result.valid;
};

export default validateSecretCode;
