<script lang="ts">
	import { EVENT_TYPE_DETAILS } from '$lib/types/event/event-type.type';
	import type { FLOAT } from '$lib/types/float/float.interface';
	import FloatProfilePicture from './atoms/FloatProfilePicture.svelte';
	import BaseFloat from './base-float/BaseFloat.svelte';
	import FloatCertificate from './float-types/FloatCertificate.svelte';
	import FloatMedal from './float-types/FloatMedal.svelte';
	import FloatTicket from './float-types/FloatTicket.svelte';

	export let float: FLOAT;
	export let showBack = false;
	export let minWidth = '300px';
	export let maxWidth = '600px';
	export let isForScreenshot = false; // When true, the float will be rendered without some details (e.g. Recipient and Float Serial )
	export let hasShadow = true;
</script>

{#if !float.visibilityMode || float.visibilityMode === 'certificate'}
	<BaseFloat {float} {showBack} {minWidth} {maxWidth} {hasShadow}>
		{#if EVENT_TYPE_DETAILS[float.eventType].certificateType === 'certificate'}
			<FloatCertificate {float} {isForScreenshot} />
		{:else if EVENT_TYPE_DETAILS[float.eventType].certificateType === 'medal'}
			<FloatMedal {float} {isForScreenshot} />
		{:else}
			<FloatTicket {float} {isForScreenshot} />
		{/if}
	</BaseFloat>
{:else if float.visibilityMode === 'picture'}
	<FloatProfilePicture {float} />
{/if}
