<script>
  import CheckAddress from '$lib/components/CheckAddress.svelte';
</script>

<style>
  
  video {
    display:block;
    width:100%;
    max-width: 800px;
    margin: 20px auto;
  }
  
  
  h1 {
    text-align:center;
  }
</style>

<svelte:head>
<title>Home</title>
</svelte:head>

<video autoplay muted loop id="myVideo">
  <source src="island.mp4" type="video/mp4" />
</video>

<h1><a href="/create" role="button">+ Create a FLOAT</a></h1>

<article>
  <h2>Check FLOATs for an Address</h2>
  <CheckAddress />
</article>

<h2>What is a FLOAT?</h2>

A FLOAT is a....
