<script>
  import { page } from "$app/stores";
import Loading from "$lib/components/common/Loading.svelte";
  import Event from "$lib/components/Event.svelte";
  import { getEventsInGroup, getGroup } from "$lib/flow/actions";

  let events = getEventsInGroup($page.params.address, $page.params.groupName);
  let group = getGroup($page.params.address, $page.params.groupName);
</script>

{#await group then group}
  <div class="grid">
    <img src="https://ipfs.infura.io/ipfs/{group.image}" alt="group" />
    <div>
      <h1>{group.name}</h1>
      <p>{group.description}</p>
    </div>
  </div>
{/await}

<div class="card-container">
  {#await events}
    <Loading />
  {:then events}
    {#each events as event}
      <Event floatEvent={{
        name: event.name,
        host: event.host,
        image: event.image,
        eventId: event.eventId
      }} />
    {/each}
  {/await}
</div>

<style>
  .grid {
    padding: 0px;
    align-items: center;
    grid-template-columns: auto 1fr;
  }
  .grid p {
    margin: 0;
  }
  .grid img {
    max-width: 400px;
    max-height: 200px;
  }

  @media screen and (max-width: 700px) {
    .grid h1 {
      font-size: 20px;
    }
    .grid img {
      max-width: 200px;
      max-height: 100px;
    }
  }
</style>