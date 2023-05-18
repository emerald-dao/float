<script lang="ts">
	import Blur from '$lib/components/Blur.svelte';
	import EventQrCard from '$lib/components/EventQRCard.svelte';
	import SectionHeading from './atoms/SectionHeading.svelte';
</script>

<section class="container-small center column-10">
	<Blur color="tertiary" right="0" top="30%" />
	<Blur left="0" bottom="20%" />
	<SectionHeading
		title="We've got you covered"
		description="Create a unique and valuable experience for event attendees, while increasing engagement and
			trust for event creators."
	/>
	<EventQrCard title="I visited FLOAT's Home Page" type="Website Visit" qrUrl="/test-qr.png" />
</section>

<style lang="scss">
	section {
		position: relative;
	}
</style>
