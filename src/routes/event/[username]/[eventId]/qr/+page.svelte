<script lang="ts">
	import { page } from '$app/stores';
	import Blur from '$lib/components/Blur.svelte';
	import EventQrCard from '$lib/components/EventQRCard.svelte';
	import generateQRCode from '$lib/utilities/generateQRCode';
	import { onMount } from 'svelte';

	export let data;

	let qrCodeDataUrl: string;

	onMount(async () => {
		let qr = `http://localhost:5173/event/${$page.params.username}/${data.overview.eventId}`;
		qrCodeDataUrl = await generateQRCode(qr);
	});
</script>

<section class="container center column-10">
	<Blur color="tertiary" right="20%" top="30%" />
	<Blur left="20%" bottom="20%" />
	<EventQrCard title="I visited FLOAT's Home Page" type="Website Visit" qrUrl={qrCodeDataUrl} />
</section>

<style lang="scss">
	section {
		position: relative;
		overflow: hidden;
	}
</style>
