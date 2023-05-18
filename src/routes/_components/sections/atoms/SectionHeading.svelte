<script lang="ts">
	export let title: string;
	export let description: string | undefined = undefined;
</script>

<div class="center column-2">
	<h2 class="w-bold">{title}</h2>
	{#if description}
		<p class="h5">
			{description}
		</p>
	{/if}
	<slot />
</div>

<style type="scss">
	h2 {
		text-align: center;
	}

	p.h5 {
		text-align: center;
		color: var(--clr-text-main);
		max-width: 45ch;
	}
</style>
