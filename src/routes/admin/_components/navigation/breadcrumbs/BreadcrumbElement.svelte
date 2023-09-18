<script lang="ts">
	export let name: string;
	export let link: string;
	export let noLink = false;
	export let hideOnMobile = false;
	export let isFirst: boolean;
</script>

{#if !isFirst}
	<span class:hide-on-mobile={hideOnMobile}>/</span>
{/if}
{#if !noLink}
	<a href={link} class="header-link" class:hide-on-mobile={hideOnMobile}>{name}</a>
{:else}
	<span class:hide-on-mobile={hideOnMobile}>{name}</span>
{/if}

<style lang="scss">
	a,
	span {
		font-size: var(--font-size-2);
	}

	a {
		color: var(--clr-text-main);
		text-decoration: none;
	}

	span {
		color: var(--clr-heading-main);
	}
</style>
