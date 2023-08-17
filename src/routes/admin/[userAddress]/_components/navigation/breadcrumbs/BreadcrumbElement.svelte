<script lang="ts">
	export let name: string;
	export let link: string;
	export let noLink = false;
</script>

{#if !noLink}
	<a href={link} class="header-link">{name}</a>
{:else}
	<span>{name}</span>
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
