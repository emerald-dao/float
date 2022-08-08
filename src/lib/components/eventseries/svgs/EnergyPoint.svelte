<script>
  export let huge = false;
</script>

<svg
  xmlns="http://www.w3.org/2000/svg"
  class="badge"
  class:huge
  viewBox="0 0 20 20"
  fill="currentColor"
>
  <path
    fill-rule="evenodd"
    d="M11.3 1.046A1 1 0 0112 2v5h4a1 1 0 01.82 1.573l-7 10A1 1 0 018 18v-5H4a1 1 0 01-.82-1.573l7-10a1 1 0 011.12-.38z"
    clip-rule="evenodd"
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
