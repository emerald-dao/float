<script>
  import CheckAddress from "$lib/components/CheckAddress.svelte";
  import Stats from "$lib/components/common/Stats.svelte";
  import Button from "$lib/components/landing/Button.svelte";
  import Comparison from "$lib/components/landing/Comparison.svelte";
  import HowWorks from "$lib/components/landing/HowWorks.svelte";
  import Testimonials from "$lib/components/landing/Testimonials.svelte";
  import UseCases from "$lib/components/landing/UseCases.svelte";
  import { PAGE_TITLE_EXTENSION } from "$lib/constants";
</script>

<svelte:head>
  <title>Home {PAGE_TITLE_EXTENSION}</title>
</svelte:head>

<div class="hero">
  <h1>A proof of attendance platform #onFlow.</h1>
  <h3>Create events for your communities to prove that they were there.</h3>
</div>

<Button />

<UseCases />

<Button />

<HowWorks />

<Button />

<Comparison />

<Testimonials />

<Button />

<style>
  .hero {
    position: relative;
    padding: 7rem 2rem 5.2rem 8rem;
  }

  .hero h1 {
    font-size: 3.2rem;
    line-height: 120%;
    font-weight: 800;
  }

  h3 {
    font-size: 1.45rem;
    font-weight: 600;
    line-height: 1.75rem;
    margin-bottom: 1rem;
  }
</style>
