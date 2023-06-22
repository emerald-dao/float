<script>
	import Icon from '@iconify/svelte';
</script>

<section class="container-small">
	<img src="/test-toucan.png" alt="float" />
	<h1 class="medium">mateor.find</h1>
	<div class="social-media">
		<div class="row media-wrapper">
			<Icon icon="tabler:brand-twitter" width="22" height="22" />
			<p>@___mateor</p>
		</div>
		<div class="row media-wrapper">
			<Icon icon="tabler:brand-twitter" width="22" height="22" />
			<p>@___mateor</p>
		</div>
		<div class="row media-wrapper">
			<Icon icon="tabler:brand-twitter" width="22" height="22" />
			<p>@___mateor</p>
		</div>
	</div>
	<div class="stats-wrapper">
		<div>
			<p class="large">26</p>
			<p class="small">FLOATs claimed</p>
		</div>
		<div>
			<p class="large">7</p>
			<p class="small">Events created</p>
		</div>
	</div>
</section>

<style type="scss">
	section {
		display: flex;
		flex-direction: column;
		justify-content: center;
		align-items: center;
		gap: var(--space-6);
		padding-block: 4rem 0;

		@include mq(small) {
			padding-block: 4rem;
		}

		img {
			width: 260px;
			height: 260px;
			border-radius: 50%;
		}

		.social-media {
			display: flex;
			flex-direction: column;
			gap: var(--space-2);

			@include mq(small) {
				flex-direction: row;
				gap: var(--space-7);
			}

			.media-wrapper {
				gap: var(--space-1);
				border: 1px solid var(--clr-border-primary);
				padding: var(--space-2) var(--space-3);
				border-radius: var(--radius-3);
			}
		}

		.stats-wrapper {
			width: 100%;
			display: grid;
			grid-template-columns: repeat(2, 1fr);
			text-align: center;
			border-top: 1px dashed var(--clr-border-primary);
			border-bottom: 1px dashed var(--clr-border-primary);
			padding: var(--space-5) 0 var(--space-5) 0;
		}
	}
</style>
