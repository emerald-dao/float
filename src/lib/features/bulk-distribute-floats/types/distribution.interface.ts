import type { MedalType } from '$lib/types/event/medal-types.type';
import type { CertificateType } from '$lib/types/event/event-type.type';

export interface Distribution<T extends CertificateType> {
	certificateType: T;
	distributionObjects: DistributionElement<T>[];
}

export interface DistributionElement<T extends CertificateType> {
	address: string;
	medal: T extends 'medal' ? MedalType : null;
}
