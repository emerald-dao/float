<script>
  import { page } from "$app/stores";
  import Loading from "$lib/components/common/Loading.svelte";
  import SeriesCardDisplay from "$lib/components/eventseries/elements/SeriesCardDisplay.svelte";
  import { getEventSeries, resolveAddressObject } from "$lib/flow/actions";
  import { getResolvedName } from "$lib/flow/utils";
  import { user } from "$lib/flow/stores";

  $: title = `EventSeries #${$page.params.seriesId}`;
  $: byHost = `by ${$page.params.host}`;
</script>

<svelte:head>
  <title>{title} {byHost}</title>
</svelte:head>

<div class="container">
  <article>
    {#await resolveAddressObject($page.params.host)}
      <Loading />
    {:then addressObject}
      {#if !addressObject.address}
        <p>
          Invalid Address: {$page.params.host}
        </p>
      {:else}
        {#await getEventSeries(addressObject.address, $page.params.seriesId)}
          <Loading />
        {:then eventSeries}
          {#if !eventSeries}
            <p>
              Failed to load eventSeries: #{$page.params.seriesId} by {$page
                .params.host}.
            </p>
          {:else}
            <header class="text-center">
              <SeriesCardDisplay
                eventSeriesData={{
                  ...eventSeries,
                  owner: getResolvedName(addressObject),
                }}
              />
            </header>
          {/if}
        {/await}
        <!-- TODO Management -->
        {#if $user?.addr == addressObject.address}
          <div>Management</div>
        {/if}
      {/if}
    {/await}
  </article>
</div>
