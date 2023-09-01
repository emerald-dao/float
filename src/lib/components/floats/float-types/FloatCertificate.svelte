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
	<div class="top-right-triangle" />
	<div class="top-left-triangle" />
	<div class="bottom-right-triangle" />
	<div class="bottom-left-triangle" />
	<FloatContent let:F>
		<F.Header>
			<FloatHeading certificateType="certificate" />
			<FloatSerialLabel
				eventId={float.eventId}
				floatSerial={float.serial}
				certificateType="certificate"
			/>
		</F.Header>
		<F.Body>
			<div class="body-wrapper">
				<div class="column align-center">
					<div class="name-and-logo-wrapper">
						<FloatLogo {float} width="8%" />
						<FloatName {float} />
					</div>
					<FloatEventType eventType={float.eventType} />
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
		background: var(--clr-surface-secondary);
		padding: 5% 7%;
		width: 100%;
		height: 100%;
		overflow: hidden;

		.body-wrapper {
			display: flex;
			flex-direction: column;
			justify-content: space-between;
			flex: 1;

			.certificate-recipient {
				font-size: 1.3em;
				// --font-weight: var(--font-weight-medium);
				color: var(--clr-text-off);
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
	}

	.bottom-right-triangle,
	.bottom-left-triangle,
	.top-right-triangle,
	.top-left-triangle {
		content: '';
		position: absolute;
		border-color: transparent;
		border-style: solid;
		border-width: 1.95em;
	}

	.bottom-right-triangle {
		bottom: 0;
		right: 0;
		border-right-color: var(--clr-background-primary);
		border-bottom-color: var(--clr-background-primary);
	}

	.bottom-left-triangle {
		bottom: 0;
		left: 0;
		border-left-color: var(--clr-background-primary);
		border-bottom-color: var(--clr-background-primary);
	}

	.top-right-triangle {
		top: 0;
		right: 0;
		border-right-color: var(--clr-background-primary);
		border-top-color: var(--clr-background-primary);
	}

	.top-left-triangle {
		top: 0;
		left: 0;
		border-left-color: var(--clr-background-primary);
		border-top-color: var(--clr-background-primary);
	}
</style>
