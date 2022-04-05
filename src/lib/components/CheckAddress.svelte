<script>
  let address;

  const onKeyPress = (e) => {
    if (e.charCode === 13) window.location = "/" + address;
  };
</script>

<div class="input-button-group">
  <input
    type="text"
    id="address"
    name="address"
    placeholder="0x00000000000"
    bind:value={address}
    on:keypress={onKeyPress} />
  <a href="/{address}" role="button" class:disabled={address}>View</a>
</div>
<small>Paste in a Flow address, .find, or .fn name.</small>

<!-- Button -->
