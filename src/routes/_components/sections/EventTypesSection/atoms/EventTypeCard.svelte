<script lang="ts">
	import { fly } from 'svelte/transition';
	import Icon from '@iconify/svelte';

	export let imageUrl: string;
	export let title: string;
	export let description: string;
	export let icon: string;
</script>

<div class="card-primary" in:fly={{ duration: 500, y: -20 }}>
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
	.card-primary {
		overflow: hidden;
		padding: 0%;

		@include mq('small') {
			display: grid;
			align-items: center;
			width: 100%;
			grid-template-columns: 2fr 2fr;
		}

		img {
			height: 12rem;
			width: 100%;
			object-fit: cover;
			border-radius: var(--radius-2);
		}

		.body {
			padding: var(--space-10);
		}
	}
</style>
