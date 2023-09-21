<script lang="ts">
	import { EVENT_TYPE_DETAILS } from '$lib/types/event/event-type.type';
	import type { FLOAT } from '$lib/types/float/float.interface';
	import getProfile from '$lib/utilities/profiles/getProfile';
	import DateReceived from '../../atoms/DateReceived.svelte';
	import EventData from '../../atoms/EventData.svelte';
	import FloatEventType from '../../atoms/FloatEventType.svelte';
	import FloatContent from '../../atoms/FloatFront/FloatFrontContent.svelte';
	import FloatHeading from '../../atoms/FloatHeading.svelte';
	import FloatLogo from '../../atoms/FloatLogo.svelte';
	import FloatName from '../../atoms/FloatName.svelte';
	import FloatSerialLabel from '../../atoms/FloatSerialLabel.svelte';
	import PoweredBy from '../../atoms/PoweredBy.svelte';
	import Profile from '../../atoms/Profile/Profile.svelte';
	import type { FloatColors } from '../../float-colors.type';

	export let float: FLOAT;
	export let labelColor: FloatColors = 'neutral';
	export let isForScreenshot = false; // When true, the float will be rendered without some details (e.g. Recipient and Float Serial )
</script>

<FloatContent let:F color={labelColor}>
	<F.Header>
		<FloatHeading
			certificateType={EVENT_TYPE_DETAILS[float.eventType].certificateType}
			color={labelColor}
			level={float.extraMetadata.medalType}
		/>
		<FloatSerialLabel
			eventId={float.eventId}
			floatSerial={float.serial}
			color={labelColor}
			{isForScreenshot}
		/>
	</F.Header>
	<F.Body color={labelColor}>
		<div class={`body-wrapper ${labelColor}`}>
			<div class="secondary-body-wrapper column align-center">
				<div class="name-and-logo-wrapper">
					<FloatLogo {float} width="1.4em" />
					<FloatName {float} fontSize="1.17em" />
				</div>
				<FloatEventType eventType={float.eventType} fontSize="0.84em" />
				{#await getProfile(float.originalRecipient) then profile}
					<div class="certificate-recipient-wrapper">
						<span class="certificate-recipient">{profile.name}</span>
					</div>
				{/await}
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

<style lang="scss">
	.body-wrapper {
		display: flex;
		flex-direction: column;
		justify-content: space-between;
		flex: 1;

		.secondary-body-wrapper {
			flex: 1;

			.certificate-recipient-wrapper {
				flex: 1;
				display: flex;
				align-items: center;

				.certificate-recipient {
					font-size: 1.38em;
					--font-weight: var(--font-weight-medium);
					color: var(--clr-heading-main);
				}
			}

			.name-and-logo-wrapper {
				display: flex;
				flex-direction: row;
				align-items: center;
				justify-content: center;
				gap: 0.5em;
				overflow: hidden;
				width: 100%;
			}
		}
	}
</style>
