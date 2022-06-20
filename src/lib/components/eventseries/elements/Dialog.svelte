<script>
  export let opened = false;
</script>

<dialog open={opened}>
  <article>
    <slot />
  </article>
</dialog>

<style>
  dialog {
    color: var(--color);
  }
</style>
