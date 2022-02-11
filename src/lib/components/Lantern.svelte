<script>
  export let ipfsHash;
</script>

<img
  class="lantern"
  style="left: {Math.floor(Math.random() * (90 - 10 + 1)) + 10}vw;"
  src="https://ipfs.infura.io/ipfs/{ipfsHash}"
  alt="lantern" />

<style>
  .lantern {
    position: absolute;
    color: lightblue;
    top: 100vh;
    opacity: 1;
    display: block;
    animation-name: slide;
    animation-fill-mode: forwards;
    animation-duration: 5s;
    animation-iteration-count: 1;
    animation-timing-function: ease-in;
  }

  img.lantern {
    width: 50px;
    height: 50px;
    object-fit: cover;
    border-radius: 100%;
    box-shadow: 0px 0px 5px 5px #38e8c6;
  }

  @keyframes slide {
    0% {
      top: 100vh;
      opacity: 1;
    }
    99% {
      top: -9vh;
      opacity: 1;
    }
    100% {
      top: -10vh;
      opacity: 0;
    }
  }

  @-webkit-keyframes slide {
    0% {
      top: 100vh;
      opacity: 1;
    }
    99% {
      top: -9vh;
      opacity: 1;
    }
    100% {
      top: -10vh;
      opacity: 0;
      display: none;
    }
  }
</style>
