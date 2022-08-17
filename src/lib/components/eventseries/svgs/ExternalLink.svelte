<script>
  export let huge = false;
</script>

<svg
  xmlns="http://www.w3.org/2000/svg"
  class="badge"
  class:huge
  fill="none"
  viewBox="0 0 24 24"
  stroke="currentColor"
  stroke-width="2"
  preserveAspectRatio="xMidYMid meet"
>
  <path
    stroke-linecap="round"
    stroke-linejoin="round"
    d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"
  />
</svg>

<style>
  .badge {
    display: inline-block;
    width: 1.2rem;
    height: 1.2rem;
  }

  .badge.huge {
    width: 2.4rem;
    height: 2.4rem;
  }
</style>
