<script lang="ts">
	import { page } from '$app/stores';
	import EventQrCard from '$lib/components/EventQRCard.svelte';
	import generateQRCode from '$lib/utilities/generateQRCode';
	import { onMount } from 'svelte';

	export let data;

	let qrCodeDataUrl: string;
	let eventUrl: string;

	onMount(async () => {
		eventUrl = `${$page.url.origin}/event/${$page.params.username}/${data.overview.eventId}`;
		qrCodeDataUrl = await generateQRCode(eventUrl);
	});
</script>

<EventQrCard
	title={data.overview.name}
	type={data.overview.eventType}
	qrUrl={qrCodeDataUrl}
	{eventUrl}
/>
