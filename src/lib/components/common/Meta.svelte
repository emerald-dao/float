<script>
  import { PAGE_TITLE_EXTENSION } from '$lib/constants';
  export let title;
  export let author;
  export let description;
  export let url;
  
</script>
<svelte:head>
<title>{title} {PAGE_TITLE_EXTENSION}</title>
<meta name="author" content="{author}">
<meta name="description" content="{description}">

<!--  Essential META Tags -->
<meta property="og:title" content="{title} {PAGE_TITLE_EXTENSION}">
<meta property="og:type" content="article" />
<meta property="og:url" content="{url}">

<!--  Non-Essential, But Recommended -->
<meta property="og:description" content="{description}">

<meta name="twitter:title" content="{title} {PAGE_TITLE_EXTENSION}" />
<meta name="twitter:description" content="{description}" />
<meta name="twitter:description" content="{description}" />

</svelte:head>