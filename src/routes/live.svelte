<script>
  import Lantern from "$lib/components/Lantern.svelte";
  import GraffleSDK from "$lib/graffle.js";
  import { onMount } from "svelte";

  const streamSDK = new GraffleSDK();

  let claimedEvents = {};

  const renderImage = (id, ipfsHash) => {
    claimedEvents[id] = ipfsHash;

    // Remove the component after 5 seconds
    setTimeout(() => {
      delete claimedEvents[id];
      claimedEvents = claimedEvents;
    }, 5000);
  };

  const receiveEvent = (message) => {
    // `message` is the event
    console.log(message);
    renderImage(message.id, message.blockEventData.eventImage);
  };

  onMount(async () => {
    console.log("Creating the stream");
    await streamSDK.stream(receiveEvent);
  });
</script>

<div id="spawner">
  <img class="island" src="/island.png" alt="FLOATing island" />
  {#each Object.keys(claimedEvents) as id (id)}
    <Lantern ipfsHash={claimedEvents[id]} />
  {/each}
</div>
<div class="graffle">
  Live feed powered by <img
    class="graffle"
    src="/graffle-logo.png"
    alt="Graffle logo" />
</div>

<style>
  .graffle {
    position: relative;
    display: flex;
    justify-content: center;
    align-items: center;
    top: 200px;
  }

  img.graffle {
    position: relative;
    top: -5px;
    width: 100px;
    height: auto;
    margin-left: 5px;
  }

  div {
    text-align: center;
  }

  .island {
    position: relative;
    width: 50%;
    animation: 8s float linear infinite;
  }

  @keyframes float {
    0% {
      top: 0px;
    }
    23% {
      top: 19px;
    }
    25% {
      top: 20px;
    }
    28% {
      top: 20px;
    }
    50% {
      top: 0px;
    }
    73% {
      top: -19px;
    }
    75% {
      top: -20px;
    }
    78% {
      top: -20px;
    }
    100% {
      top: 0px;
    }
  }
</style>
