<script>
  export let address;
  export let abbreviated = false;
</script>

<style>
  .led-green {
    position:relative;
    display:inline-block;
    top: 0px;
    margin-right:0.5em;
    background-color: var(--primary);
    width: 14px;
    height: 14px;
    border-radius: 14px;
  }
</style>

<div>
  <span class="led-green"></span>
  <span class="mono">{abbreviated ? '0x...' + address.slice(address.length - 4) : address}</span>
</div>