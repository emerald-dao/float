<script lang="ts">
	import type { FLOAT } from '$lib/types/float/float.interface';
	import getProfile from '$lib/utilities/profiles/getProfile';
	import Profile from '../atoms/Profile/Profile.svelte';
	import FloatSerialLabel from '../atoms/FloatSerialLabel.svelte';
	import PoweredBy from '../atoms/PoweredBy.svelte';
	import FloatHeading from '../atoms/FloatHeading.svelte';
	import EventData from '../atoms/EventData.svelte';
	import DateReceived from '../atoms/DateReceived.svelte';
	import FloatContent from '../atoms/FloatFront/FloatFrontContent.svelte';
	import FloatLogo from '../atoms/FloatLogo.svelte';
	import FloatName from '../atoms/FloatName.svelte';
	import FloatEventType from '../atoms/FloatEventType.svelte';

	export let float: FLOAT;
	export let isForScreenshot = false; // When true, the float will be rendered without some details (e.g. Recipient and Float Serial )
</script>

<div class="float-front">
	<FloatContent let:F>
		<F.Header>
			<FloatHeading certificateType="ticket" />
			<FloatSerialLabel eventId={float.eventId} floatSerial={float.serial} {isForScreenshot} />
		</F.Header>
		<F.Body>
			<div class="logo-and-name-wrapper">
				<FloatLogo {float} />
				<div class="name-wrapper">
					<FloatName {float} />
					<FloatEventType eventType={float.eventType} />
				</div>
			</div>
			<div class="row-space-between">
				<EventData title="Organizer">
					<Profile address={float.eventHost} />
				</EventData>
				{#if !isForScreenshot}
					<EventData title="Recipient" align="right">
						<Profile address={float.originalRecipient} inverse={true} />
					</EventData>
				{/if}
			</div>
		</F.Body>
		<F.Footer>
			{#if !isForScreenshot}
				<DateReceived dateReceived={float.dateReceived} />
			{:else}
				<div />
			{/if}
			<PoweredBy />
		</F.Footer>
	</FloatContent>
</div>

<style lang="scss">
	.float-front {
		position: absolute;
		width: 100%;
		height: 100%;
		-webkit-backface-visibility: hidden; /* Safari */
		backface-visibility: hidden;
		top: 0;
		border-radius: 2em;
		background: radial-gradient(
				circle at left center,
				transparent 4%,
				var(--clr-surface-secondary) 4%,
				var(--clr-surface-secondary) 80%,
				transparent 0
			),
			radial-gradient(
				circle at right center,
				transparent 4%,
				var(--clr-surface-secondary) 4%,
				var(--clr-surface-secondary) 80%,
				transparent 0
			);
		mask-image: radial-gradient(
				circle at left center,
				transparent 4%,
				var(--clr-surface-secondary) 4%,
				var(--clr-surface-secondary) 80%,
				transparent 0
			),
			radial-gradient(
				circle at right center,
				transparent 4%,
				var(--clr-surface-secondary) 4%,
				var(--clr-surface-secondary) 80%,
				transparent 0
			);
		padding: 5% 5.5%;
		width: 100%;
		height: 100%;
		position: relative;
		transition: transform 1.4s;
		transform-style: preserve-3d;

		.logo-and-name-wrapper {
			display: flex;
			align-items: center;
			gap: 0.8em;

			.name-wrapper {
				width: 100%;
				overflow: hidden;
			}
		}
	}
</style>
