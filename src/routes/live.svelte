<script>
  import Lantern from "$lib/components/Lantern.svelte";
  import LibLoader from '$lib/components/LibLoader.svelte';
  import { getStats } from "$lib/flow/actions";
  import GraffleSDK from "$lib/graffle.js";
  import { onMount } from "svelte";
  
  let claimedEvents = {};
  
  let isSignalrReady = false;
  let streamCreated = false;

  let addition = 0;

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
    addition++;
  };

  function createStream() {
    if(!streamCreated) {
      const streamSDK = new GraffleSDK();
      streamSDK.stream(receiveEvent);
    }
    streamCreated = true;
  }
  
  onMount(() => {
    if(window?.signalR) {
      createStream()
    }
  });
  // const streamSDK = new GraffleSDK();
  // onMount(async () => {
  //   console.log("Creating the stream");
  //   streamSDK.stream(receiveEvent);
  // });
</script>

 
<LibLoader
  url="https://cdnjs.cloudflare.com/ajax/libs/microsoft-signalr/6.0.2/signalr.min.js"
  on:loaded={() => createStream() }
  uniqueId={+new Date()}
/> 

<div id="spawner">
  <img class="island" src="/island.png" alt="FLOATing island" />
  <br />
  <br />
  <br />
  {#await getStats() then stats}
    <div class="info">
      <p>Total # of FLOATs: {stats[0] + addition}</p>
      <p>Total # of Events: {stats[1]}</p>
    </div>
  {/await}
  {#each Object.keys(claimedEvents) as id (id)}
    <Lantern ipfsHash={claimedEvents[id]} />
  {/each}
</div>

<style>
  #spawner {
    text-align: center;
  }
  .info {
    display: flex;
    justify-content: center;
    align-items: center;
    flex-direction: column;
  }
  .info p {
    border: 1px dotted var(--primary);
    width: 250px;
    color: var(--contrast);
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