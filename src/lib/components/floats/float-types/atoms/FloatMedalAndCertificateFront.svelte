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
	import Profile from '../../atoms/Profile.svelte';

	export let float: FLOAT;
	export let labelColor: 'primary' | 'gold' | 'silver' | 'bronze' = 'primary';
</script>

<FloatContent let:F color={labelColor}>
	<F.Header>
		<FloatHeading
			certificateType={EVENT_TYPE_DETAILS[float.eventType].certificateType}
			color={labelColor}
		/>
		<FloatSerialLabel eventId={float.eventId} floatSerial={float.serial} color={labelColor} />
	</F.Header>
	<F.Body color={labelColor}>
		<div class={`body-wrapper ${labelColor}`}>
			<div class="column align-center">
				<div class="name-and-logo-wrapper">
					<FloatLogo {float} width="5.7%" />
					<FloatName {float} fontSize="1.17em" />
				</div>
				<FloatEventType eventType={float.eventType} fontSize="0.84em" />
				{#await getProfile(float.originalRecipient) then profile}
					<span class="certificate-recipient">{profile.name}</span>
				{/await}
			</div>
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
	</F.Body>
	<F.Footer>
		<DateReceived dateReceived={float.dateReceived} />
		<PoweredBy />
	</F.Footer>
</FloatContent>

<style lang="scss">
	.body-wrapper {
		display: flex;
		flex-direction: column;
		justify-content: space-between;
		flex: 1;

		.certificate-recipient {
			font-size: 1.38em;
			--font-weight: var(--font-weight-medium);
			color: var(--clr-heading-main);
			margin-top: 3%;
		}

		.name-and-logo-wrapper {
			display: flex;
			flex-direction: row;
			align-items: center;
			justify-content: center;
			gap: 0.5em;
		}
	}
</style>
