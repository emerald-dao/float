<script>
  export let ipfsHash;
  export let direction = "creation";

  $: display = false;

  let timeout = Math.random() * 20000;

  setTimeout(() => (display = true), timeout);
  setTimeout(() => (display = false), timeout + 6000);
</script>

{#if display}
  <img
    class="lantern"
    class:creation={direction === "creation"}
    class:incineration={direction === "incineration"}
    style="left: {direction === 'creation'
      ? Math.floor(Math.random() * (90 - 10 + 1)) + 10
      : Math.floor(Math.random() * (70 - 30 + 1)) + 30}vw;"
    src="https://ipfs.io/ipfs/{ipfsHash}"
    alt="lantern"
  />
{/if}

<style>
  .lantern {
    position: absolute;
    color: lightblue;
    opacity: 1;
    display: block;
    animation-fill-mode: forwards;
    animation-duration: 5s;
    animation-iteration-count: 1;
    animation-timing-function: ease-in;
    z-index: 10;
  }

  img.lantern {
    width: 60px;
    height: 60px;
    object-fit: cover;
    border-radius: 100%;
    box-shadow: 0px 0px 5px 5px #38e8c6;
  }

  .creation {
    top: 100vh;
    animation-name: slideUp;
  }

  .incineration {
    top: -5vh;
    animation-name: slideDown;
  }

  @keyframes slideUp {
    0% {
      top: 100vh;
      opacity: 1;
    }
    85% {
      opacity: 1;
    }
    99% {
      transform: translateY(-109vh);
      opacity: 0.1;
    }
    100% {
      transform: translateY(-110vh);
      opacity: 0;
    }
  }

  @-webkit-keyframes slideUp {
    0% {
      top: 100vh;
      opacity: 1;
    }
    85% {
      opacity: 1;
    }
    99% {
      transform: translateY(-109vh);
      opacity: 0.1;
    }
    100% {
      transform: translateY(-110vh);
      opacity: 0;
    }
  }

  @keyframes slideDown {
    0% {
      top: -5vh;
      opacity: 1;
    }
    85% {
      opacity: 1;
    }
    99% {
      transform: translateY(109vh);
      opacity: 0.1;
    }
    100% {
      transform: translateY(110vh);
      opacity: 0;
    }
  }

  @-webkit-keyframes slideDown {
    0% {
      top: -5vh;
      opacity: 1;
    }
    85% {
      opacity: 1;
    }
    99% {
      transform: translateY(109vh);
      opacity: 0.1;
    }
    100% {
      transform: translateY(110vh);
      opacity: 0;
    }
  }
</style>
