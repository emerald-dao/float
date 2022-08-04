<script>
  import { createEventDispatcher } from "svelte";
  import { user, getLatestTokenList } from "$lib/flow/stores";
  import { getTokenBalances } from "$lib/flow/actions";

  // dispatcher
  const dispatch = createEventDispatcher();

  let currentToken = "";

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

  function selectToken() {
    // TODO
  }
</script>

<details role="list">
  <summary aria-haspopup="listbox">
    {currentToken ?? "please choose one"}
  </summary>
  <ul role="listbox">
    {#await ownedList then list}
      {#each list as token}
        <li>
          <a>
            <div class="flex-wrap between flex-gap">
              <span>
                <img src={token.logoURI} class="icon" /> &nbsp; {token.name}
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
  .icon {
    height: 2rem;
    width: 2rem;
  }
</style>
