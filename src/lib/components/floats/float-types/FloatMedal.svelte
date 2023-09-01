<script lang="ts">
	import type { FLOAT } from '$lib/types/float/float.interface';
	import getProfile from '$lib/utilities/profiles/getProfile';
	import DateReceived from '../atoms/DateReceived.svelte';
	import EventData from '../atoms/EventData.svelte';
	import FloatEventType from '../atoms/FloatEventType.svelte';
	import FloatContent from '../atoms/FloatFront/FloatFrontContent.svelte';
	import FloatHeading from '../atoms/FloatHeading.svelte';
	import FloatLogo from '../atoms/FloatLogo.svelte';
	import FloatName from '../atoms/FloatName.svelte';
	import FloatSerialLabel from '../atoms/FloatSerialLabel.svelte';
	import PoweredBy from '../atoms/PoweredBy.svelte';
	import Profile from '../atoms/Profile.svelte';

	export let float: FLOAT;
</script>

<div class="float-front">
	<FloatContent let:F isMedal={true}>
		<F.Header>
			<FloatHeading certificateType="medal" />
			<FloatSerialLabel
				eventId={float.eventId}
				floatSerial={float.serial}
				certificateType="medal"
			/>
		</F.Header>
		<F.Body isMedal={true}>
			<div class="body-wrapper">
				<div class="column align-center">
					<div class="name-and-logo-wrapper">
						<FloatLogo {float} width="8%" />
						<FloatName {float} />
					</div>
					<FloatEventType eventType={float.eventType} />
				</div>
				<div class="row-space-between">
					{#await getProfile(float.eventHost) then profile}
						<EventData title="Organizer">
							<Profile {profile} isMedal={true} />
						</EventData>
					{/await}
					{#await getProfile(float.originalRecipient) then profile}
						<EventData title="Recipient" align="right">
							<Profile {profile} isMedal={true} inverse={true} />
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
		padding: 5% 7%;
		width: 100%;
		height: 100%;
		background: linear-gradient(
			150deg,
			rgb(253, 241, 204) 0%,
			rgb(255, 250, 232) 20%,
			rgb(255, 246, 221) 30%,
			rgb(255, 249, 227) 60%,
			rgb(255, 244, 217) 70%,
			rgb(255, 251, 234) 85%,
			rgb(255, 245, 216) 90%,
			rgb(255, 246, 217) 100%
		);

		.body-wrapper {
			display: flex;
			flex-direction: column;
			justify-content: space-between;
			flex: 1;

			.name-and-logo-wrapper {
				display: flex;
				flex-direction: row;
				align-items: center;
				justify-content: center;
				gap: 0.5em;
			}
		}
	}
</style>
