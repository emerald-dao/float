<script>
  import { reverseLookupNames, queryEmeraldId } from '$lib/flow/actions'
  import { isFlowAddr, ellipseStr, logoPaths } from '$lib/helper'

  export let address
  export let abbreviated = false
  export let simplify = false

  let names = []
  let emeraldInfo = null

  if (isFlowAddr(address)) {
    names = reverseLookupNames(address)
    emeraldInfo = queryEmeraldId(address)
  }

  let defaultAddr = abbreviated ? ellipseStr(address) : address

  const renderName = (nameStr = '') => {
    const nameArr = nameStr.split('.')
    // const userName = nameArr[0]
    const idName = nameArr[1]
    // if (idName === 'eid') {
    //   return simplify ? address : ''
    // }

    return nameStr ? (nameStr.length > 15 && abbreviated ? ellipseStr(nameStr) : nameStr) : ''
  }
</script>

<div>
  {#if !simplify}
    <span class="led-green" />
  {/if}
  <span class="mono">
    {#await names}
      {defaultAddr}
    {:then names}
      {#if names?.length > 0}
        {#each names as name}
          <span>
            {renderName(name)}
            {#if !simplify && name}
              <img
                style="height:20px;width:auto;border-radius:50%;"
                alt="logo"
                src={logoPaths[name.split('.')[1]]}
              />
            {/if}
          </span>
        {/each}
      {:else}
        {defaultAddr}
      {/if}
    {/await}
    {#await emeraldInfo}
      {''}
    {:then emeraldInfo}
      {#if !simplify}
        <img style="height:20px;width:auto;border-radius:50%;" alt="logo" src={logoPaths['eid']} />
      {/if}
    {/await}
  </span>
</div>

<style>
  .led-green {
    position: relative;
    top: 0px;
    display: inline-block;
    width: 14px;
    height: 14px;
    margin-right: 0.5em;
    background-color: var(--primary);
    border-radius: 14px;
  }
</style>
