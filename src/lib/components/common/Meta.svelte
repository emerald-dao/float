<script>
  import { PAGE_TITLE_EXTENSION } from '$lib/constants';
  export let title;
  export let author;
  export let description;
  export let url;
  
</script>
<svelte:head>
<title>{title || "Welcome to FLOAT"} {PAGE_TITLE_EXTENSION}</title>
<meta name="description" content="{description || "Create and view FLOATs, a proof of attendance platform built by Emerald City DAO built on Flow"}" />
<meta name="author" content="{author || "Emerald City"}">
<meta property="og:image" content="http://floats.city/social-card.png">
<meta property="twitter:image" content="http://floats.city/social-card.png">
<meta name="twitter:card" content="summary_large_image">
<meta property="og:title" content="FLOATs by Emerald City DAO">
<meta property="og:type" content="article" />
<meta property="og:url" content="{url || "https://floats.city" }">

<!--  Non-Essential, But Recommended -->
<meta property="og:description" content="{description || "Create and view FLOATs, a proof of attendance platform built by Emerald City DAO built on Flow"}">
<meta property="og:site_name" content="FLOATs.city">
<meta name="twitter:image:alt" content="FLOATs.city">

<meta name="twitter:title" content="FLOATs by Emerald City DAO" />
<meta name="twitter:description" content="{description || "Create and view FLOATs, a proof of attendance platform built by Emerald City DAO built on Flow"}" />

<!--  Non-Essential, But Required for Analytics -->
<meta name="twitter:site" content="@emerald_dao">

</svelte:head>