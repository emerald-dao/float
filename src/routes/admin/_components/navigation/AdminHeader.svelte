<script lang="ts">
	import { page } from '$app/stores';
	import Icon from '@iconify/svelte';

	export let route: string | null;
	export let userName: string;
	export let userAvatar: string;
</script>

<div class="header-wrapper">
	<header>
		<div class="main-wrapper">
			<div class="row-4">
				<a href="/user/{userName}">
					<img src={userAvatar} alt="float" />
				</a>
				{#if $page.params.id}
					<p>
						<a href="/user/{userName}">{userName} </a> / <a href="/admin/{route}">{route}</a> / #{$page
							.params.id}
					</p>
				{:else}
					<p><a href="/user/{userName}">{userName} </a> / <a href="/admin/{route}">{route}</a></p>
				{/if}
			</div>
		</div>
		<div class="icon-wrapper">
			<a href="/" class="header-link">
				<Icon icon="tabler:home" width="25" />
			</a>
		</div>
	</header>
</div>

<style lang="scss">
	header {
		display: flex;
		flex-direction: row;
		justify-content: space-between;
		padding: 0 var(--space-14);
		border-bottom: 0.1px var(--clr-border-primary) solid;

		@include mq(medium) {
			display: grid;
			grid-template-columns: 1fr auto;
			gap: var(--space-8);
		}

		.main-wrapper {
			padding: var(--space-3) 0;

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
		}
		.icon-wrapper {
			display: flex;
			align-items: center;
			justify-content: flex-end;

			@include mq(medium) {
				padding-right: var(--space-1);
			}
		}
	}
</style>
