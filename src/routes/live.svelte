<script>
  import Lantern from "$lib/components/Lantern.svelte";
  import LibLoader from "$lib/components/LibLoader.svelte";
  import { getStats } from "$lib/flow/actions";
  import GraffleSDK from "$lib/graffle.js";
  import { onMount } from "svelte";
  import { PAGE_TITLE_EXTENSION } from "$lib/constants";

  let claimedEvents = {};

  let isSignalrReady = false;
  let streamCreated = false;

  let addition = 0;

  const renderImage = (id, ipfsHash, eventHost, eventId) => {
    claimedEvents[id] = { ipfsHash, eventHost, eventId };

    // Remove the component after 5 seconds
    setTimeout(() => {
      delete claimedEvents[id];
      claimedEvents = claimedEvents;
    }, 5000);
  };

  const receiveEvent = (message) => {
    // `message` is the event
    console.log(message);
    renderImage(
      message.id,
      message.blockEventData.eventImage,
      message.blockEventData.eventHost,
      message.blockEventData.eventId
    );
    addition++;
  };

  function createStream() {
    if (!streamCreated) {
      const streamSDK = new GraffleSDK();
      streamSDK.stream(receiveEvent);
    }
    streamCreated = true;
  }

  onMount(() => {
    if (window?.signalR) {
      createStream();
    }
  });
  // const streamSDK = new GraffleSDK();
  // onMount(async () => {
  //   console.log("Creating the stream");
  //   streamSDK.stream(receiveEvent);
  // });
</script>

<svelte:head>
  <title>Live Feed {PAGE_TITLE_EXTENSION}</title>
</svelte:head>

<LibLoader
  url="https://cdnjs.cloudflare.com/ajax/libs/microsoft-signalr/6.0.2/signalr.min.js"
  on:loaded={() => createStream()}
  uniqueId={+new Date()} />

<div id="spawner">
  <img class="island" src="/island.png" alt="FLOATing island" />

  {#await getStats() then stats}
    <div class="grid info">
      <p>
        FLOATs Claimed<br /><span
          >{(stats[0] + addition).toLocaleString()}</span>
      </p>
      <p>Events Created<br /><span>{stats[1].toLocaleString()}</span></p>
    </div>
  {/await}
  {#each Object.keys(claimedEvents) as id (id)}
    <a href="/{claimedEvents[id].eventHost}/event/{claimedEvents[id].eventId}">
      <Lantern ipfsHash={claimedEvents[id].ipfsHash} />
    </a>
  {/each}
</div>

<style>
  #spawner {
    text-align: center;
  }
  .info {
    margin-top: 30px;
  }
  .info p {
    line-height: 1.1;
    font-size: 0.8rem;
  }

  .info span {
    color: var(--contrast);
    font-size: 2.3rem;
    font-weight: 900;
  }
  .island {
    position: relative;
    width: 50%;
    animation: 8s float linear infinite;
  }
  @keyframes float {
    0% {
      transform: translateY(0);
    }
    23% {
      transform: translateY(19px);
    }
    25% {
      transform: translateY(20px);
    }
    28% {
      transform: translateY(20px);
    }
    50% {
      transform: translateY(0);
    }
    73% {
      transform: translateY(-19px);
    }
    75% {
      transform: translateY(-20px);
    }
    78% {
      transform: translateY(-20px);
    }
    100% {
      transform: translateY(0);
    }
  }
</style>
