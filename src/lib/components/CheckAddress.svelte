<script>
  import { isFlowAddr } from '$lib/helper'
  import { resolveFindOwnerAddrByName, resolveFlownsOwnerAddrByName } from '$lib/flow/actions'

  let search = ''
  let errorTips = ''
  let addressDom = ''

  const handleSearch = async () => {
    if (search === '') return
    errorTips = ''
    search = search.trim()
    search = search.toLowerCase()
    if (!isFlowAddr(search)) {
      const nameArr = search.split('.')
      const name = nameArr[0]
      const rootName = nameArr[1]

      let resolveReq = null
      if (rootName == 'find') {
        resolveReq = resolveFindOwnerAddrByName(name)
      } else if (rootName == 'fn') {
        resolveReq = resolveFlownsOwnerAddrByName(name)
      } else {
        // without root name resolve
        resolveReq = Promise.all([
          resolveFindOwnerAddrByName(name),
          resolveFlownsOwnerAddrByName(name),
        ])
      }

      let result = await resolveReq

      if (rootName && isFlowAddr(result)) {
        addressDom = `<span> Flowns owner: <a href='/${result}'>${name}.${rootName}</a> <b>${result}</b></span>`
      } else if (result && result.length > 0) {
        const findOwner = result[0]
        const flownsOwner = result[1]
        if (!findOwner && !flownsOwner) {
          errorTips = 'Canont resolve domain name'
          return
        }
        addressDom = `
        <div>
          ${
            findOwner
              ? `<span> Find name: <a onClick="window.location='/${findOwner}'">${name}.find</a></span> ${findOwner} <br/>`
              : ''
          }
          ${
            flownsOwner
              ? `<span> Flowns name: <a onClick="window.location='/${flownsOwner}'">${name}.fn</a></span> ${flownsOwner}`
              : ''
          }
        </div>
          `
      } else {
        addressDom = ''
        errorTips = 'Canont resolve domain name'
      }
    } else {
      errorTips = 'Search param is not valid'
    }
  }

  const onKeyPress = (e) => {
    addressDom = ''
    errorTips = ''
    if (e.charCode === 13) handleSearch()
  }
</script>

<div class="input-button-group">
  <input
    type="text"
    id="address"
    name="address"
    placeholder="0x0..00 / find.find / flowns.fn"
    bind:value={search}
    on:keypress={onKeyPress}
  />
  <div role="button" on:click={handleSearch} class:disabled={search}>View</div>
</div>
{#if addressDom}
  <div contenteditable="false" bind:innerHTML={addressDom} />
{/if}
{#if errorTips}
  <error>{errorTips}</error>
{/if}
{#if !addressDom && !errorTips}
  <small>Paste in a Flow address / .Find / Flowns name.</small>
{/if}

<!-- Button -->
