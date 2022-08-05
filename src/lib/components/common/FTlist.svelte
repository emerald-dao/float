<script>
  import { createEventDispatcher } from "svelte";
  import { user, getLatestTokenList } from "$lib/flow/stores";
  import { getTokenBalances } from "$lib/flow/actions";

  /** @type {[{ identifier: string , balance: string }]} */
  export let balances = [];
  export let watchStatus = null;

  // dispatcher
  const dispatch = createEventDispatcher();

  /** @type {import('flow-native-token-registry').TokenInfo & {balance: number}} */
  let currentToken = undefined;
  let open = false;

  async function getOwnedTokenList(address, txStatus) {
    const allList = await getLatestTokenList();
    let balancesToFill = balances;
    if (balancesToFill.length === 0 && address) {
      balancesToFill = await getTokenBalances(
        address,
        allList.map((one) => one.path.balance.slice("/public/".length))
      );
    }

    /** @type {{[key: string]: string}} */
    const dic = balancesToFill.reduce((prev, curr) => {
      prev[curr.identifier] = curr.balance;
      return prev;
    }, {});

    if (Object.keys(dic).length > 0) {
      const ret = allList
        .map((one) => {
          const identifier = `A.${one.address.slice(2)}.${
            one.contractName
          }.Vault`;
          return Object.assign(one, { balance: dic[identifier] ?? "0" });
        })
        .filter((one) => one.balance > 0);
      // update current balance
      if (currentToken) {
        const found = ret.find(
          (one) =>
            one.address === currentToken.address &&
            one.contractName == currentToken.contractName
        );
        if (found) {
          currentToken.balance = found.balance;
        }
        dispatch("balanceUpdated", currentToken);
      }
      return ret;
    } else {
      return [];
    }
  } // end function

  $: ownedList = getOwnedTokenList($user?.addr, watchStatus && $watchStatus);
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
