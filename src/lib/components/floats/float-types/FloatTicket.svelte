<script lang="ts">
	import type { FLOAT } from '$lib/types/float/float.interface';
	import getProfile from '$lib/utilities/profiles/getProfile';
	import Profile from '../atoms/Profile.svelte';
	import FloatSerialLabel from '../atoms/FloatSerialLabel.svelte';
	import PoweredBy from '../atoms/PoweredBy.svelte';
	import FloatHeading from '../atoms/FloatHeading.svelte';
	import FloatName from '../atoms/FloatName.svelte';
	import EventData from '../atoms/EventData.svelte';
	import DateReceived from '../atoms/DateReceived.svelte';

	export let float: FLOAT;
</script>

<div class="float-front">
	<div class="content">
		<div class="header-wrapper">
			<FloatHeading />
			<FloatSerialLabel eventId={float.eventId} floatSerial={float.serial} />
		</div>
		<div class="body-wrapper">
			<FloatName {float} />
			<div class="row-space-between">
				{#await getProfile(float.eventHost) then profile}
					<EventData title="Organizer">
						<Profile {profile} />
					</EventData>
				{/await}
				{#await getProfile(float.originalRecipient) then profile}
					<EventData title="Recipient" align="right">
						<Profile {profile} inverse={true} />
					</EventData>
				{/await}
			</div>
		</div>
		<div class="footer-wrapper">
			<DateReceived dateReceived={float.dateReceived} />
			<PoweredBy />
		</div>
	</div>
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

		.content {
			border: 2px solid var(--clr-neutral-badge);
			border-radius: 1.3em;
			width: 100%;
			height: 100%;
			display: flex;
			align-items: center;
			justify-content: center;
			overflow: hidden;
		}
	}

	.float-front {
		position: relative;
		transition: transform 1.4s;
		transform-style: preserve-3d;

		.content {
			border-style: solid;
			display: grid;
			grid-template-rows: auto 1fr auto;
			grid-template-columns: 100%;

			.header-wrapper,
			.footer-wrapper {
				display: flex;
				flex-direction: row;
				align-items: center;
			}

			.header-wrapper {
				padding: 2.4% 5.5%;
				justify-content: space-between;
			}

			.footer-wrapper {
				padding: 1.8% 5.5%;
				justify-content: space-between;
				width: 100%;
			}

			.body-wrapper {
				padding: 4% 5.5%;
				display: flex;
				flex-direction: column;
				justify-content: space-between;
				gap: 0.8em;
				border-block: 2px dashed var(--clr-neutral-badge);
				height: 100%;
				text-align: left;
			}
		}
	}
</style>
