<script>
  import { page } from "$app/stores";
  import Loading from "$lib/components/common/Loading.svelte";
  import Float from "$lib/components/Float.svelte";
  import { getFLOATEvent } from "$lib/flow/actions.js";

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
