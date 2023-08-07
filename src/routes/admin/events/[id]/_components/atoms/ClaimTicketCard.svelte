<script lang="ts">
	import type { Claim } from '$lib/types/event/event-claim.interface';
	import { UserProfileLabel } from '@emerald-dao/component-library';

	export let claim: Claim;
</script>

<div class="main-wrapper">
	<div class="left-wrapper">
		<UserProfileLabel address={claim.address} imageSize="40px" fontSize="var(--font-size-1)" />
	</div>
	<div class="right-wrapper">
		<div class="row-4">
			<p class="xsmall serial">
				<span>Serial</span>
				<span class="w-medium">
					{claim.serial}
				</span>
			</p>
			<p class="xsmall id w-medium">#{claim.id}</p>
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
		border-radius: var(--radius-2);
		padding: var(--space-2) var(--space-4);
		gap: var(--space-4);
		min-width: 280px;

		@include mq(small) {
			flex-direction: row;
			justify-content: space-between;
			width: 100%;
		}

		.left-wrapper {
			display: flex;
			gap: var(--space-3);
			align-items: center;
			width: 100%;
		}

		.right-wrapper {
			display: flex;
			justify-content: center;
			align-items: center;
			gap: var(--space-2);

			@include mq(small) {
				justify-content: flex-end;
			}

			.serial {
				display: flex;
				flex-direction: row;
				gap: var(--space-1);

				span:first-child {
					color: var(--clr-text-off);
				}
			}

			.id {
				color: var(--clr-text-off);
			}
		}
	}
</style>
