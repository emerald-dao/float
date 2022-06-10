<script>
  //Row component is optional and only serves to render odd/even row, you can use <tr> instead.
  //Sort component is optional

  import Table, { Row, Sort } from "./Table.svelte";
  import { sortNumber } from "./sorting.js";

  import { getHoldersInEvent } from "$lib/flow/actions.js";

  export let address = "";
  export let eventId = "";
  export let totalClaimed = 0;

  let MAX_CLAIMED_AUTO_SHOW_THRESHOLD = 9999;

  // only show claims table automatically if there are less than 10,000 claims
  let showClaims = totalClaimed < MAX_CLAIMED_AUTO_SHOW_THRESHOLD;

  let getRows = async () => {
    console.log("potato");
    let event = await getHoldersInEvent(address, eventId);
    return Object.values(event);
  };

  let promise = getRows();

  let pageCount = 0; //first page
  let pageSize = 25;

  function onCellClick(row) {
    return; // window.location = `/${row.address}`
  }

  function onSortNumber(event) {
    event.detail.rows = sortNumber(
      event.detail.rows,
      event.detail.dir,
      event.detail.key
    );
  }
</script>


{#if showClaims}
{#await promise}
  <div aria-busy="true" />
{:then rows}
  <Table
    {pageCount}
    {pageSize}
    {rows}
    let:rows={rows2}
    labels={{ empty: "This FLOAT has not been claimed yet." }}>
    <thead slot="head">
      <tr>
        <th>
          Serial
          <Sort key="serial" on:sort={onSortNumber} />
        </th>
        <th> Address </th>
      </tr>
    </thead>
    <tbody>
      {#each rows2 as row, index (row)}
        <Row {index} on:click={() => onCellClick(row)}>
          <td data-label="Serial"
            ><a href="/{row.address}/float/{row.id}"
              ><code>#{row.serial}</code></a
            ></td>
          <td data-label="Address"
            ><span class="mono"><a href="/{row.address}">{row.address}</a></span
            ></td>
        </Row>
      {/each}
    </tbody>
  </Table>
{/await}
{:else}

  <p>This FLOAT is very popular! 🎉 To be mindful of network load, we won't load the list of who claimed this FLOAT automatically. You are welcome to click on the button below to load it manually!</p>
  <button on:click={() => showClaims = true}>View list of who claimed this FLOAT</button>

{/if}
