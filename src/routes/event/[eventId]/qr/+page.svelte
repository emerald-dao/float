<script type="ts">
	import Blur from '$lib/components/Blur.svelte';
	import EventQrCard from '$lib/components/EventQRCard.svelte';
</script>

<section class="container center column-10">
	<Blur color="tertiary" right="20%" top="30%" />
	<Blur left="20%" bottom="20%" />
	<EventQrCard title="I visited FLOAT's Home Page" type="Website Visit" qrUrl="/test-qr.png" />
</section>

<style lang="scss">
	section {
		position: relative;
		overflow: hidden;
	}
</style>
