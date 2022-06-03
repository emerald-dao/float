<script>
import { configureFCLAndLogin } from "$lib/flow/actions";



</script>

<article>
  <div class="wallet">
    <button id="blocto" on:click={() => configureFCLAndLogin('blocto')}><img src="/blocto-logo.jpg" alt="blocto logo" />Connect Blocto</button>
  </div>
  <div class="wallet">
    <button id="dapper" on:click={() => configureFCLAndLogin('dapper')}><img src="/dapper-logo.png" alt="dapper logo" />Connect Dapper</button>
  </div>
</article>

<style>
  article {
    position: fixed;
    top: 50%;
    left: 50%;
    transform: translateX(-50%) translateY(-50%);
    width: 600px;
    background-color: var(--h1-color);
    color: var(--primary);
    border: 3px solid var(--primary);
  }

  .wallet {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin: 10px;
  }

  button {
    display: flex;
    align-items: center;
    justify-content: center;
    border: none;
  }

  button img {
    width: 50px;
    height: 50px;
    border-radius: 100%;
    margin-right: 20px;
  }

  button:hover {
    opacity: .8;
  }

  #blocto {
    background-image: linear-gradient(135deg,#72e9f3 -20%,#404de6 120%);
  }

  #dapper {
    background-image: linear-gradient(to top, #c471f5 0%, #fa71cd 100%);
  }
</style>