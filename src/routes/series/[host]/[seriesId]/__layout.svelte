<script>
  import { page } from "$app/stores";
  import { goto } from "$app/navigation";
  import Loading from "$lib/components/common/Loading.svelte";
  import SeriesCardDisplay from "$lib/components/eventseries/elements/SeriesCardDisplay.svelte";
  import { getEventSeries, resolveAddressObject } from "$lib/flow/actions";
  import { getResolvedName } from "$lib/flow/utils";
  import { user } from "$lib/flow/stores";

  $: baseUri = `/series/${$page.params.host}/${$page.params.seriesId}`;
  $: title = `EventSeries #${$page.params.seriesId}`;

  $: pageKey = $page.routeId.slice("series/[host]/[seriesId]".length);
  $: isIndexPage = pageKey === "" || pageKey === undefined;
  $: isTreasuryPage = pageKey === "/treasury";
  $: isSettingsPage = pageKey === "/settings";
</script>

<svelte:head>
  <title>{title} by {$page.params.host}</title>
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
            <header>
              <SeriesCardDisplay
                eventSeriesData={{
                  ...eventSeries,
                  owner: getResolvedName(addressObject),
                }}
              />
            </header>
            <ul class="tabs">
              <li
                on:click={() => {
                  if (!isIndexPage) {
                    goto(baseUri);
                  }
                }}
                class:animatedlink={!isIndexPage}
                class:selected={isIndexPage}
              >
                Information
              </li>
              <li
                on:click={() => {
                  if (!isTreasuryPage) {
                    goto(baseUri + "/treasury");
                  }
                }}
                class:animatedlink={!isTreasuryPage}
                class:selected={isTreasuryPage}
              >
                Treasury
              </li>
              {#if $user?.addr == addressObject.address}
                <li
                  on:click={() => {
                    if (!isSettingsPage) {
                      goto(baseUri + "/settings");
                    }
                  }}
                  class:animatedlink={!isSettingsPage}
                  class:selected={isSettingsPage}
                >
                  Settings
                </li>
              {/if}
            </ul>

            <slot />
          {/if}
        {/await}
      {/if}
    {/await}
  </article>
</div>

<!-- FIXME: COPY FROM [address]/index, maybe set in app.css is better  -->
<style>
  .animatedlink {
    display: inline-block;
    position: relative;
  }

  .animatedlink:after {
    content: "";
    position: absolute;
    width: 100%;
    transform: scaleX(0);
    height: 2px;
    bottom: 0;
    left: 0;
    background-color: var(--primary);
    transform-origin: bottom right;
    transition: transform 0.25s ease-out;
  }

  .animatedlink:hover:after {
    transform: scaleX(1);
    transform-origin: bottom left;
  }

  .selected {
    color: var(--primary);
    border-bottom: 2px solid var(--primary);
  }

  .tabs {
    display: flex;
    justify-content: space-around;
  }

  .tabs li {
    list-style-type: none;
    font-size: 18px;
    text-transform: uppercase;
    font-weight: bold;
    cursor: pointer;
    padding: 0px 10px;
  }

  .tabs li.selected {
    cursor: default;
  }

  @media screen and (max-width: 767px) {
    .tabs {
      margin: 0px;
    }
    .tabs li {
      font-size: 15px;
    }
  }
</style>
