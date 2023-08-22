<script lang="ts">
	import { EVENT_TYPE_DETAILS } from '$lib/types/event/even-type.type';
	import type { FLOAT } from '$lib/types/float/float.interface';
	import BaseFloat from './base-float/BaseFloat.svelte';
	import FloatCertificate from './float-types/FloatCertificate.svelte';
	import FloatTicket from './float-types/FloatTicket.svelte';

	export let float: FLOAT;
	export let showBack = false;
	export let minWidth = '300px';
	export let maxWidth = '600px';
</script>

<BaseFloat {float} {showBack} {minWidth} {maxWidth}>
	{#if EVENT_TYPE_DETAILS[float.eventType].certificateType !== 'ticket'}
		<FloatCertificate {float} />
	{:else}
		<FloatTicket {float} />
	{/if}
</BaseFloat>
