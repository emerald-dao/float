<script>
  import { createEventDispatcher } from "svelte";
  import { user, getLatestTokenList } from "$lib/flow/stores";
  import { getTokenBalances } from "$lib/flow/actions";

  // dispatcher
  const dispatch = createEventDispatcher();

  /** @type {import('flow-native-token-registry').TokenInfo} */
  let currentToken = undefined;
  let open = false;

  async function getOwnedTokenList(address) {
    const allList = await getLatestTokenList();
    if (address) {
      const result = await getTokenBalances(
        address,
        allList.map((one) => one.path.balance.slice("/public/".length))
      );
      /** @type {Map<string, import('../types').TokenBalance>} */
      const dic = result.reduce((prev, curr) => {
        prev.set(curr.identifier, curr);
        return prev;
      }, new Map());
      return allList
        .map((one) => {
          let balance = 0;
          const identifier = `A.${one.address.slice(2)}.${
            one.contractName
          }.Vault`;
          if (dic.has(identifier)) {
            balance = dic.get(identifier).balance;
          }
          return Object.assign(one, { balance });
        })
        .filter((one) => one.balance > 0);
    } else {
      return [];
    }
  } // end function

  $: ownedList = getOwnedTokenList($user?.addr);
</script>

<details role="list" {open}>
  <summary
    aria-haspopup="listbox"
    on:click={(e) => {
      setTimeout(() => {
        if (!open) {
          open = true;
        }
      });
    }}
  >
    {#if !currentToken}
      please choose your token
    {:else}
      <img src={currentToken.logoURI} class="icon" alt="currentToken logo" />
      &nbsp; {currentToken.name}
    {/if}
  </summary>
  <ul role="listbox">
    {#await ownedList then list}
      {#each list as token}
        <li>
          <!-- svelte-ignore a11y-missing-attribute -->
          <a
            on:click={(e) => {
              dispatch("select", token);
              currentToken = token;
              open = false;
            }}
          >
            <div class="flex-wrap between flex-gap">
              <span>
                <img src={token.logoURI} class="icon" alt="{token.name} logo" />
                &nbsp; {token.name}
              </span>
              <span class="emphasis">{token.balance}</span>
            </div>
          </a>
        </li>
      {:else}
        <li>You have no Token with balance.</li>
      {/each}
    {/await}
  </ul>
</details>

<style>
  img.icon {
    height: 1.5rem;
    width: 1.5rem;
  }
</style>
