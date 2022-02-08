<script>
  import { PAGE_TITLE_EXTENSION } from '$lib/constants';
  export let title;
  export let author;
  export let description;

</script>
<svelte:head>
  <title>{title} {PAGE_TITLE_EXTENSION}</title>
  <meta name="author" content="{author}">
  <meta name="description" content="{description}">
</svelte:head>