import { distributeFLOATsExecution } from '$flow/actions';
import type { CertificateType } from '$lib/types/event/event-type.type';
import type { Distribution } from '../types/distribution.interface';

export const distributeFloats = async <T extends CertificateType>(
	eventId: string,
	distribution: Distribution<T>
) => {
	return await distributeFLOATsExecution(eventId, distribution);
};
