import { burnFLOATExecution } from "$flow/actions";

const burnFloat = async (floatId: string) => {
	return await burnFLOATExecution(floatId);
};

export default burnFloat;
