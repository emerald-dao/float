<script type="ts">
	export let claim: Claim;

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
			<p class="small">#32</p>
			<div class="row-3">
				<img src={claim.image} width={'30px'} height={'30px'} alt="logo" />
				<p>0x2f3043tpx3f43g</p>
			</div>
		</div>
		<div class="right-wrapper">
			<div class="row-2">
				<p>17:32</p>
				<p>04/20/23</p>
			</div>
		</div>
	</div>
</div>

<style type="scss">
	.main-wrapper {
		display: flex;
		flex-direction: column;
		justify-content: center;
		align-items: flex-start;
		padding: var(--space-2) var(--space-12);
		gap: var(--space-6);

		.wrapper {
			display: grid;
			grid-template-columns: 0.9fr 1fr;
			justify-content: space-between;
			border: var(--border-width-primary) dashed var(--clr-border-primary);
			border-radius: var(--radius-4);
			padding: var(--space-3) var(--space-4);
			width: 100%;

			.left-wrapper {
				display: grid;
				grid-template-columns: 0.2fr 1fr;
				align-items: center;
				gap: var(--space-1);

				.row-3 {
					align-items: center;
					background-color: var(--clr-neutral-500);
					border-radius: 100px;

					img {
						border-radius: 50%;
					}
				}
			}

			.right-wrapper {
				display: flex;
				justify-content: flex-end;
				align-items: center;
				gap: var(--space-2);
			}
		}
	}
</style>
