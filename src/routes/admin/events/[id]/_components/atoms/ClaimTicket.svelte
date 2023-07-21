<script lang="ts">
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
	<div class="wrapper">
		<div class="left-wrapper">
			<p class="small">#{i + 1}</p>
			<div class="row-3">
				<img src={claim.image} width={'30px'} height={'30px'} alt="logo" />
				<p>{claim.walletAddress}</p>
			</div>
		</div>
		<div class="right-wrapper">
			<div class="row-2">
				<p>{claim.time}</p>
				<p>{claim.date}</p>
			</div>
		</div>
	</div>
</div>

<style lang="scss">
	.main-wrapper {
		display: flex;
		flex-direction: column;
		justify-content: center;
		align-items: center;
		padding: var(--space-2) var(--space-2);

		.wrapper {
			display: flex;
			flex-direction: column;
			border: var(--border-width-primary) dashed var(--clr-border-primary);
			border-radius: var(--radius-4);
			padding: var(--space-3) var(--space-4);
			gap: var(--space-4);
			min-width: 280px;
			width: 50%;

			@include mq(medium) {
				display: grid;
				justify-content: space-between;
				grid-template-columns: 0.9fr 1fr;
				width: fit-content;
			}

			.left-wrapper {
				display: flex;
				gap: var(--space-4);
				align-items: center;

				@include mq(medium) {
					display: grid;
					grid-template-columns: 0.2fr 1fr;
					gap: var(--space-1);
				}

				.row-3 {
					align-items: center;
					background-color: rgba(133, 133, 133, 0.1);
					border-radius: 100px;
					width: max-content;
					padding-right: var(--space-2);

					img {
						border-radius: 50%;
					}
				}
			}

			.right-wrapper {
				display: flex;
				justify-content: flex-start;
				align-items: center;
				gap: var(--space-2);

				@include mq(medium) {
					justify-content: flex-end;
				}
			}
		}
	}
</style>
