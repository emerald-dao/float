<script lang="ts">
	import { page } from '$app/stores';
	import Icon from '@iconify/svelte';

	export let route: string | null;
</script>

<header>
	<div class="container-large main-wrapper row">
		<div class="row-4">
			<img src="/test-toucan.png" alt="float" />
			{#if $page.params.id}
				<p>mateor.find / {route} / #{$page.params.id}</p>
			{:else}
				<p>mateor.find / {route}</p>
			{/if}
		</div>
		<a href="/">
			<Icon icon="iconamoon:home-light" color="var(--clr-primary-main)" width="30" height="30" />
		</a>
	</div>
</header>

<style lang="scss">
	header {
		background-color: var(--clr-background-primary);
		z-index: 999;
		border-bottom: 0.1px var(--clr-border-primary) solid;
	}
	.main-wrapper {
		padding: var(--space-3) 0;
		top: 10px;
		gap: var(--space-4);
		justify-content: space-between;

		.row-4 {
			align-items: center;
			img {
				width: 56px;
				height: 56px;
				border-radius: 50%;
			}

			p {
				color: var(--clr-heading-main);
			}
		}

		a {
			display: flex;
			align-items: center;
		}
	}
</style>
