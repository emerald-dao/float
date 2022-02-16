<script>
  import { page } from "$app/stores";
  import Loading from "$lib/components/common/Loading.svelte";
  import Float from "$lib/components/Float.svelte";
  import { getEvent, getHoldersInEvent, getFLOAT, transferFLOAT } from "$lib/flow/actions.js";
  import Meta from '$lib/components/common/Meta.svelte';
  import { user } from "$lib/flow/stores";

  let owner = null;
  let serial = $page.params.serial;
  let id = null;
  let float = null;
  const floatEventCallback = async () => {
    return new Promise(async (resolve, reject) => {
      let data = await getEvent($page.params.address, $page.params.eventId);
      
      let holders = await getHoldersInEvent($page.params.address, $page.params.eventId);
      owner = holders?.currentHolders[serial]?.address;
      id = holders?.currentHolders[serial]?.id;
      float = await getFLOAT(owner, id);
      console.log("FLOAT Data:", float);
      console.log("Event Data:", {...holders, ...data})
      resolve({...holders, ...data});
    })
  }
  let recipientAddr = "";

  let floatEvent = floatEventCallback();
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
      {#if owner}
        <h3>Owned by {owner}</h3>
        <small class="muted">Original Recipient: {float?.originalRecipient}</small>
      {:else}
        <h3>This FLOAT was deleted.</h3>
        <small class="muted">Original Recipient: Unknown</small>
      {/if}
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
  {#if owner === $user.addr}
    <article>
      <label for="recipientAddr">
        Copy the recipient's address below.
        <input
          type="text"
          name="recipientAddr"
          bind:value={recipientAddr}
          placeholder="recipient's address"
        />
      </label>
      <button on:click={transferFLOAT(float?.id, recipientAddr)}>Transfer this FLOAT</button>
    </article>
  {/if}
{/await}

<style>
  article {
    text-align: center;
    align-items: center;
  
  }

</style>
