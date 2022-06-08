<script>
  import { configureFCLAndLogin } from "$lib/flow/actions";
  import { walletModal } from "$lib/stores";
</script>

<article>
  <button id="x" on:click={() => ($walletModal = false)}>x</button>
  <header>
    <h1>Choose your wallet</h1>
  </header>
  <div class="wallet">
    <button id="blocto" on:click={() => configureFCLAndLogin("blocto")}>
      <img src="/blocto-logo.jpg" alt="blocto logo" />
      <span>Connect Blocto</span>
    </button>
  </div>
  <div class="wallet">
    <button id="dapper" on:click={() => configureFCLAndLogin("dapper")}>
      <img src="/dapper-logo.png" alt="dapper logo" />
      <span>Connect Dapper</span>
    </button>
  </div>
  <div class="wallet">
    <button id="other" on:click={() => configureFCLAndLogin("other")}>
      <img src="/lilico-logo.jpg" alt="lilico logo" />
      <span>Connect Lilico</span>
    </button>
  </div>
</article>

<style>
  #x {
    position: fixed;
    top: 5px;
    right: 5px;
    width: 20px;
    height: 20px;
    display: flex;
    justify-content: center;
    align-items: center;
    padding: 15px;
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

  #other {
    background-image: linear-gradient(135deg, #f5ba71 -20%, #ff7a62 120%);
  }
</style>
