<script lang="ts">
	import Icon from '@iconify/svelte';

	export let imageUrl: string;
	export let title: string;
	export let description: string;
	export let icon: string;
</script>

<div class="main-wrapper">
	<img src={imageUrl} alt={`${title} event`} />
	<div class="column-2 body">
		<div class="row-2 align-center">
			<Icon {icon} width="1.6rem" color="var(--clr-heading-main)" />
			<h4 class="h5 w-medium">{title}</h4>
		</div>
		<p>{description}</p>
	</div>
</div>

<style lang="scss">
	.main-wrapper {
		border-radius: var(--radius-5);
		background-color: var(--clr-background-secondary);
		overflow: hidden;

		@include mq('small') {
			display: grid;
			align-items: center;
			width: 100%;
			grid-template-columns: 2fr 3fr;
		}

		img {
			height: 18rem;
			width: 100%;
			object-fit: cover;
		}

		.body {
			padding: var(--space-10);
		}
	}
</style>
