import { distributeFLOATsExecution, distributeMedalFLOATsExecution } from '$flow/actions';
import type { CertificateType } from '$lib/types/event/event-type.type';
import type { Distribution } from '../types/distribution.interface';

export const distributeFloats = async <T extends CertificateType>(
	eventId: string,
	distribution: Distribution<T>
) => {
	if (distribution.certificateType === 'medal') {
		return await distributeMedalFLOATsExecution(eventId, distribution.distributionObjects.map(obj => obj.address), distribution.distributionObjects as { address: string, medal: string }[])
	}
	return await distributeFLOATsExecution(eventId, distribution.distributionObjects.map(obj => obj.address));
};
