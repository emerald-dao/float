import { validateAddressExistance, validateFindExistance } from "$flow/actions";

const validateUserExistance = async (value: string) => {
	if (value.length == 18 && value.startsWith('0x')) {
		return await validateAddressExistance(value);
	}
	// take away trailing .find if it has it
	if (value.substring(value.length - 5) === 'find') {
		value = value.substring(0, value.length - 5)
	}
	return await validateFindExistance(value);
};

export default validateUserExistance;
