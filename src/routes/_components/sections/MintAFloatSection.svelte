<script lang="ts">
	import Blur from '$lib/components/Blur.svelte';
	import EventQrCard from '$lib/components/EventQRCard.svelte';
	import { onMount } from 'svelte';
	import SectionHeading from './atoms/SectionHeading.svelte';
	import { page } from '$app/stores';
	import { network } from '$flow/config';
	import generateQRCode from '$lib/utilities/generateQRCode';

	let eventId: string = network === 'mainnet' ? '1287289901' : network === 'testnet' ? '173143134' : '';
	let username: string =
		network === 'mainnet' ? 'jacob' : network === 'testnet' ? '0xd7f69a06f10eae0e' : '';
	let qrCodeDataUrl = '';

	onMount(async () => {
		let qr = `${$page.url.origin}/event/${username}/${eventId}`;
		qrCodeDataUrl = await generateQRCode(qr);
	});
</script>

<section class="container-small center column-10">
	<Blur color="tertiary" right="0" top="30%" />
	<Blur left="0" bottom="20%" />
	<SectionHeading
		title="Start collecting experiences"
		description="Mint this FLOAT to start your collection!"
	/>
	<EventQrCard title="I visited FLOAT's Home Page" type="Website Visit" qrUrl={qrCodeDataUrl} />
</section>

<style lang="scss">
	section {
		position: relative;
	}
</style>
