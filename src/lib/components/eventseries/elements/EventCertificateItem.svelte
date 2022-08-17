<script>
  import { t } from "svelte-i18n";
  import EventItem from "./EventItem.svelte";

  export let event;
  export let points;
  export let owned = false;
</script>

<div class="cert-panel flex-wrap flex-gap" class:owned>
  <EventItem
    item={{
      event: {
        host: event.host,
        id: event.eventId,
      },
      required: false,
    }}
    {owned}
    preview={true}
  />
  <div class="flex-auto flex flex-col">
    <span> {$t("challenges.elements.strategy.display.points")} </span>
    <span class="emphasis"> {points} </span>
  </div>
</div>

<style>
  .cert-panel {
    padding: 0 1rem 0 0;
    border-radius: var(--border-radius);
    box-shadow: var(--card-box-shadow);
  }

  .cert-panel.owned {
    border: 1px solid var(--secondary);
    opacity: 0.2;
  }
</style>
