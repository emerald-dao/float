<script>
  export let owned = false;
  export let required = false;
  export let huge = false;
</script>

{#if owned}
  <svg
    class="badge"
    class:huge
    xmlns="http://www.w3.org/2000/svg"
    viewBox="0 0 20 20"
    preserveAspectRatio="xMidYMid meet"
  >
    <path
      fill-rule="evenodd"
      d="M6.267 3.455a3.066 3.066 0 001.745-.723 3.066 3.066 0 013.976 0 3.066 3.066 0 001.745.723 3.066 3.066 0 012.812 2.812c.051.643.304 1.254.723 1.745a3.066 3.066 0 010 3.976 3.066 3.066 0 00-.723 1.745 3.066 3.066 0 01-2.812 2.812 3.066 3.066 0 00-1.745.723 3.066 3.066 0 01-3.976 0 3.066 3.066 0 00-1.745-.723 3.066 3.066 0 01-2.812-2.812 3.066 3.066 0 00-.723-1.745 3.066 3.066 0 010-3.976 3.066 3.066 0 00.723-1.745 3.066 3.066 0 012.812-2.812zm7.44 5.252a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
      clip-rule="evenodd"
    />
  </svg>
{:else if required}
  <svg
    class="badge outline opacity"
    class:huge
    xmlns="http://www.w3.org/2000/svg"
    viewBox="0 0 24 24"
    preserveAspectRatio="xMidYMid meet"
  >
    <path
      stroke-linecap="round"
      stroke-linejoin="round"
      d="M9 12l2 2 4-4M7.835 4.697a3.42 3.42 0 001.946-.806 3.42 3.42 0 014.438 0 3.42 3.42 0 001.946.806 3.42 3.42 0 013.138 3.138 3.42 3.42 0 00.806 1.946 3.42 3.42 0 010 4.438 3.42 3.42 0 00-.806 1.946 3.42 3.42 0 01-3.138 3.138 3.42 3.42 0 00-1.946.806 3.42 3.42 0 01-4.438 0 3.42 3.42 0 00-1.946-.806 3.42 3.42 0 01-3.138-3.138 3.42 3.42 0 00-.806-1.946 3.42 3.42 0 010-4.438 3.42 3.42 0 00.806-1.946 3.42 3.42 0 013.138-3.138z"
    />
  </svg>
{/if}

<style>
  .badge {
    display: inline-block;
    fill: var(--primary);
    width: 1rem;
    height: 1rem;
  }

  .badge.huge {
    width: 2rem;
    height: 2rem;
  }

  .badge.outline {
    fill: var(--background-color);
    stroke: var(--primary);
    stroke-width: 2;
  }

  .badge.opacity {
    fill-opacity: 0.3;
    stroke-opacity: 0.3;
  }
</style>
