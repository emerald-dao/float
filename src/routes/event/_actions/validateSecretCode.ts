import { validateSecretCodeForClaim } from "$flow/actions";

const validateSecretCode = async (eventId: string, eventHost: string, secretCode: string, claimee: string) => {
	return await validateSecretCodeForClaim(eventId, eventHost, secretCode, claimee)
};

export default validateSecretCode;
