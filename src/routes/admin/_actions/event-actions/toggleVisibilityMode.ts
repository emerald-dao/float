import { toggleVisibilityModeExecution } from "$flow/actions";

const toggleVisibilityMode = async (eventId: string) => {
    return await toggleVisibilityModeExecution(eventId);
};

export default toggleVisibilityMode;
