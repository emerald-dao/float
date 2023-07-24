<script lang="ts">
	import { page } from '$app/stores';
	import Icon from '@iconify/svelte';

	export let route: string | null;
	export let userName: string;
	export let userAvatar: string;
</script>

<header>
	<div class="main-wrapper row">
		<div class="row-4">
			<img src={userAvatar} alt="float" />
			{#if $page.params.id}
				<p>
					<a href="/admin/{route}">{userName} </a> / <a href="/admin/{route}">{route}</a> / #{$page
						.params.id}
				</p>
			{:else}
				<p>{userName} / <a href="/admin/{route}">{route}</a></p>
			{/if}
		</div>
		<a href="/">
			<Icon icon="tabler:home" color="var(--clr-primary-main)" width="30" height="30" />
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
		padding: var(--space-3) var(--space-18) var(--space-3) var(--space-19);
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

			a {
				display: inline;
				text-decoration: none;
				color: var(--clr-heading-main);
			}
		}

		a {
			display: flex;
			align-items: center;
		}
	}
</style>
