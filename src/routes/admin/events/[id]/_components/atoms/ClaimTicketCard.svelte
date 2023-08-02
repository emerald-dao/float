<script lang="ts">
	import { UserProfileLabel } from '@emerald-dao/component-library';

	export let claim: Claim;
	export let i: number;

	interface Claim {
		image: string;
		walletAddress: string;
		time: string;
		date: string;
	}
</script>

<div class="main-wrapper">
	<div class="left-wrapper">
		<p class="small">#{i + 1}</p>
		<UserProfileLabel
			address={claim.walletAddress}
			imageSize="30px"
			fontSize="var(--font-size-0)"
		/>
	</div>
	<div class="right-wrapper">
		<div class="row-4">
			<p class="xsmall">{claim.time}</p>
			<p class="xsmall">{claim.date}</p>
		</div>
	</div>
</div>

<style lang="scss">
	.main-wrapper {
		display: flex;
		flex-direction: column;
		justify-content: center;
		align-items: center;
		border: var(--border-width-primary) dashed var(--clr-border-primary);
		border-radius: var(--radius-4);
		padding: var(--space-2) var(--space-4);
		gap: var(--space-4);
		min-width: 280px;

		@include mq(small) {
			display: grid;
			justify-content: space-between;
			grid-template-columns: 0.9fr 1fr;
			width: 100%;
		}

		.left-wrapper {
			display: flex;
			gap: var(--space-3);
			align-items: center;
		}

		.right-wrapper {
			display: flex;
			justify-content: center;
			align-items: center;
			gap: var(--space-2);

			@include mq(small) {
				justify-content: flex-end;
			}
		}
	}
</style>
