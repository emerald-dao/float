<script>
  import { page } from "$app/stores";
  import Loading from "$lib/components/common/Loading.svelte";
  import Float from "$lib/components/Float.svelte";
  import { getFLOATEvent } from "$lib/flow/actions.js";
  import Meta from '$lib/components/common/Meta.svelte';

  let owner = null;
  let serial = $page.params.serial;
  let floatEvent = getFLOATEvent(
    $page.params.address,
    $page.params.eventId
  ).then((result) => {
    floatEvent = result;
    let claimed = floatEvent.claimed;
    Object.keys(claimed).map(function (address, index) {
      if (claimed[address].serial == serial) {
        owner = address;
      }
    });
  });
</script>

{#await floatEvent}
  <Loading />
{:then floatEvent}

  <Meta
  title="{floatEvent?.name} | FLOAT #{$page.params.eventId}"
  author={floatEvent?.host}
  description={floatEvent?.description}
  url={$page.url}
  />

  <article>
    <header>
      <h3>Owned by {owner}</h3>
    </header>
    <Float
      float={{
        eventHost: floatEvent?.host,
        eventId: floatEvent?.id,
        eventMetadata: {
          name: floatEvent?.name,
          image: floatEvent?.image,
          totalSupply: floatEvent?.totalSupply
        },
        serial: serial,
      }}
      preview={false}
    />
  </article>
{/await}

<style>
  article {
    text-align: center;
    align-items: center;
  
  }

</style>
