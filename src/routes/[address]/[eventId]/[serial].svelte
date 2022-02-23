<script>
  import { page } from "$app/stores";
  import Loading from "$lib/components/common/Loading.svelte";
  import Float from "$lib/components/Float.svelte";
  import { getEvent, getFLOAT, transferFLOAT, getCurrentHolder, deleteFLOAT } from "$lib/flow/actions.js";
  import Meta from '$lib/components/common/Meta.svelte';
  import { user } from "$lib/flow/stores";

  const floatEventCallback = async () => {
    return new Promise(async (resolve, reject) => {
      let event = await getEvent($page.params.address, $page.params.eventId);
      
      let holder = await getCurrentHolder($page.params.address, $page.params.eventId, $page.params.serial)
      let float = await getFLOAT(holder?.address, holder?.id);
      
      console.log({event, float})
      resolve({event, float});
    })
  }
  let recipientAddr = "";

  let data = floatEventCallback();
</script>

{#await data}
  <Loading />
{:then data}

  <Meta
    title="{data?.event.name} | FLOAT #{$page.params.eventId}"
    author={data?.event.host}
    description={data?.event.description}
    url={$page.url}
  />

  <article>
    <header>
      {#if data?.float.owner}
        <h3>Owned by {data?.float.owner === $user.addr ? "you" : data?.float.owner}</h3>
        <small class="muted">Originally received by {data?.float.originalRecipient}</small>
      {:else}
        <h3>This FLOAT was deleted.</h3>
        <small class="muted">Original Recipient: Unknown</small>
      {/if}
    </header>
    <Float
      float={{
        eventHost: data?.event.host,
        eventId: data?.event.id,
        eventMetadata: {
          name: data?.event.name,
          image: data?.event.image,
          totalSupply: data?.event.totalSupply
        },
        serial: data?.float.serial,
      }}
      preview={false}
    />
    <blockquote>
      <strong><small class="muted">DESCRIPTION</small></strong><br
      />{data?.event.description}
    </blockquote>
    <footer>
      {#if $user?.addr == data?.float.owner}
          <div class="toggle">
            <button
              class="outline red"
              on:click={() => deleteFLOAT(data?.float.id)}
            >
              Delete this FLOAT
            </button>
          </div>
        {/if}
    </footer>
  </article>
  {#if data?.float.owner === $user.addr}
    <article>
      <label for="recipientAddr">
        Copy the recipient's address below.
        <input
          type="text"
          name="recipientAddr"
          bind:value={recipientAddr}
          placeholder="0x00000000000"
        />
      </label>
      <button on:click={transferFLOAT(data?.float.id, recipientAddr)}>Transfer this FLOAT</button>
    </article>
  {/if}
{/await}

<style>
  article {
    text-align: center;
    align-items: center;
  
  }

  .muted {
    font-size: 0.7rem;
    opacity: 0.7;
  }

  blockquote {
    text-align: left;
  }

</style>
