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
    d="M3 12v3c0 1.657 3.134 3 7 3s7-1.343 7-3v-3c0 1.657-3.134 3-7 3s-7-1.343-7-3z"
  />
  <path
    d="M3 7v3c0 1.657 3.134 3 7 3s7-1.343 7-3V7c0 1.657-3.134 3-7 3S3 8.657 3 7z"
  />
  <path d="M17 5c0 1.657-3.134 3-7 3S3 6.657 3 5s3.134-3 7-3 7 1.343 7 3z" />
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
