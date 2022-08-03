<script>
  // import CheckAddress from "$lib/components/CheckAddress.svelte";
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
  <h1>Proof of attendance #onFlow.</h1>
  <h3>Create events for your communities to prove that they were there.</h3>
</div>

<Stats />

<!-- <video
  src="/updated_float.mp4"
  alt="FLOAT Video - Freakizoid"
  autoplay
  controls
  loop /> -->

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
    padding: 3rem 2rem 2rem 8rem;
  }

  .hero h1 {
    font-size: 3.2rem;
    line-height: 120%;
    font-weight: 800;
  }

  video {
    position: relative;
    width: 50%;
    left: 25%;
    text-align: center;
    border-radius: 0.4rem;
  }

  h3 {
    font-size: 1.45rem;
    font-weight: 600;
    line-height: 1.75rem;
    margin-bottom: 1rem;
  }

  @media all and (max-width: 768px) {
    .hero {
      padding-left: 2rem;
    }

    video {
      width: 75%;
      left: 12.5%;
    }
  }
</style>
