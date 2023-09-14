<script lang="ts">
	import BreadcrumbElement from './breadcrumbs/BreadcrumbElement.svelte';
	import { profile, user } from '$lib/stores/flow/FlowStore';
	import { page } from '$app/stores';
	import Icon from '@iconify/svelte';

	const createBreadcrumbs = (pathname: string) => {
		const path = pathname.split('/');
		const pathWithoutAdmin = path.slice(1);
		const pathWithoutAdminLength = pathWithoutAdmin.length;

		const breadcrumbs = [];

		for (let i = 0; i < pathWithoutAdminLength; i++) {
			const name = i === 0 ? $profile?.name ?? $user.addr : pathWithoutAdmin[i];
			const link = `/${pathWithoutAdmin.slice(0, i + 1).join('/')}`;

			breadcrumbs.push({
				name,
				link
			});
		}

		return breadcrumbs;
	};

	$: breadcrumbs = createBreadcrumbs($page.url.pathname);
</script>

<header>
	<div class="main-wrapper">
		<div class="row-4 align-center">
			<a href="/u/{$profile?.address}">
				<img src={$profile?.avatar} alt="float" />
			</a>
			<div class="row-2">
				{#each breadcrumbs as breadcrumb, i}
					{@const last = i == breadcrumbs.length - 1}
					{@const first = i == 0}
					<BreadcrumbElement
						name={breadcrumb.name}
						link={breadcrumb.link}
						noLink={last || first}
						isFirst={first}
						hideOnMobile={!first}
					/>
				{/each}
			</div>
		</div>
	</div>
	<div class="icon-wrapper">
		<a href="/" class="header-link">
			<Icon icon="tabler:home" width="25" />
		</a>
	</div>
</header>

<style lang="scss">
	header {
		display: flex;
		flex-direction: row;
		justify-content: space-between;
		padding: 0 var(--space-6);
		border-bottom: 0.1px var(--clr-border-primary) solid;

		@include mq(medium) {
			display: grid;
			grid-template-columns: 1fr auto;
			gap: var(--space-8);
			padding: 0 var(--space-14);
		}

		.main-wrapper {
			padding: var(--space-3) 0;

			img {
				width: 56px;
				height: 56px;
				border-radius: 50%;
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
