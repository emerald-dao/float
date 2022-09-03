<script>
  import { t } from "svelte-i18n";
  import EventItem from "./EventItem.svelte";

  export let event;
  export let points;
  export let owned = false;
  export let preview = true;

  function getPoints(data) {
    const challengeCertificateVerifier =
      data?.verifiers[
        Object.keys(data?.verifiers ?? {}).find((key) =>
          key.endsWith("FLOATVerifiers.ChallengeAchievementPoint")
        )
      ];
    return !challengeCertificateVerifier
      ? 0
      : challengeCertificateVerifier[0].challengeThresholdPoints;
  }
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
    {preview}
    let:eventData
  >
    <div class="flex-auto flex flex-col" slot="after">
      <small> {$t("challenges.elements.strategy.display.require")} </small>
      <small> {$t("challenges.elements.strategy.display.points")} </small>
      <span class="emphasis"> {points ?? getPoints(eventData)} </span>
    </div>
  </EventItem>
</div>

<style>
  .cert-panel {
    padding: 0 1rem 0 0;
    border-radius: 10px;
    box-shadow: var(--card-box-shadow);
  }

  .cert-panel.owned {
    border: 1px solid var(--secondary);
  }
</style>
