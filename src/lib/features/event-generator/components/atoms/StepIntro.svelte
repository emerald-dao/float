<script lang="ts">
	export let title: string | undefined;
	export let description: string | undefined;
</script>

{#if description || title}
	<div class="column-1">
		{#if title}
			<h2 class="h5 w-medium">{title}</h2>
		{/if}
		{#if description}
			<p>{description}</p>
		{/if}
	</div>
{/if}
