<script>
  import { t } from "svelte-i18n";
  export let full = false;
</script>

<small class="panel-tag alert-success" class:full-width={full}>
  {$t("challenges.elements.item.primary")}
</small>

<style>
  .full-width {
    width: 100%;
  }
  .panel-tag {
    font-family: monospace;
    font-weight: 600;
    font-size: xx-small;
  }
</style>
