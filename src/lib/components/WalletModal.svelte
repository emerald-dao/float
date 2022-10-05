<script>
  import { configureFCLAndLogin } from "$lib/flow/actions";
  import { discoveryAuthnServices } from "$lib/flow/stores";
  import { walletModal } from "$lib/stores";

  let services;

  discoveryAuthnServices.subscribe(s => services = s.results)
</script>

<article>
  <button id="x" on:click={() => ($walletModal = false)}>
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width="16"
      height="16"
      fill="currentColor"
      class="bi bi-x"
      viewBox="0 0 16 16">
      <path
        d="M4.646 4.646a.5.5 0 0 1 .708 0L8 7.293l2.646-2.647a.5.5 0 0 1 .708.708L8.707 8l2.647 2.646a.5.5 0 0 1-.708.708L8 8.707l-2.646 2.647a.5.5 0 0 1-.708-.708L7.293 8 4.646 5.354a.5.5 0 0 1 0-.708z" />
    </svg>
  </button>
  <header>
    <h1>Choose your wallet</h1>
  </header>
  {#each services as service}
    <div class="wallet">
      <button id={service.provider.name} on:click={() => configureFCLAndLogin(service)}>
        <img src={service.provider.icon} alt={`${service.provider.name} logo`} />
        <span>Connect {service.provider.name}</span>
      </button>
    </div>
  {/each}
</article>

<style>
  #x {
    position: absolute;
    top: 5px;
    right: 5px;
    width: 30px;
    height: 30px;
    display: flex;
    padding: 0;
    justify-content: center;
    align-items: center;
    background: none;
  }

  #x svg {
    position: relative;
    color: var(--primary);
    width: 30px;
    height: 30px;
  }

  article {
    position: fixed;
    top: 50%;
    left: 50%;
    transform: translateX(-50%) translateY(-50%);
    max-width: 600px;
    width: 100%;
    background-color: var(--card-background-color);
    color: var(--primary);
    border: 3px solid var(--primary);
    z-index: 10000;
  }

  .wallet {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin: 10px;
  }

  h1 {
    text-align: center;
  }

  button {
    display: flex;
    align-items: center;
    justify-content: flex-start;
    border: none;
  }

  button img {
    width: 50px;
    height: 50px;
    border-radius: 100%;
    margin-right: 20px;
  }

  button span {
    flex-grow: 1;
  }

  button:hover {
    opacity: 0.8;
  }

  #blocto {
    background-image: linear-gradient(135deg, #72e9f3 -20%, #404de6 120%);
  }

  #dapper {
    background-image: linear-gradient(135deg, #c471f5 -20%, #fa71cd 120%);
  }

  #lilico {
    background-image: linear-gradient(135deg, #f5ba71 -20%, #ff7a62 120%);
  }
</style>
