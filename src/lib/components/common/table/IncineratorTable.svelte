<script>
  //Row component is optional and only serves to render odd/even row, you can use <tr> instead.
  //Sort component is optional

  import Table, { Row, Sort } from "./Table.svelte";
  import { sortNumber, sortString } from "./sorting.js";
  import { page } from "$app/stores";
  import { formatter } from "$lib/flow/utils";
  import { selectedToBurn } from "./stores";

  export let floats;
  let rows = floats;

  if (rows?.length > 0) {
    rows = rows.sort((a, b) => b.dateReceived - a.dateReceived);
  }

  let pageCount = 0;
  let pageSize = 10;

  function onCellClick(row) {
    return;
  }

  function onSortNumber(event) {
    event.detail.rows = sortNumber(
      event.detail.rows,
      event.detail.dir,
      event.detail.key
    );
  }

  function onSortString(event) {
    event.detail.rows = sortString(
      event.detail.rows,
      event.detail.dir,
      event.detail.key
    );
  }

  function toggleBurn(float) {
    console.log(float);
    if (float.id in $selectedToBurn) {
      delete $selectedToBurn[float.id];
    } else {
      $selectedToBurn[float.id] = float;
    }
    $selectedToBurn = $selectedToBurn;
    console.log($selectedToBurn);
  }
</script>

<Table
  {pageCount}
  {pageSize}
  {rows}
  let:rows={rows2}
  labels={{
    empty: "This account has not claimed any FLOATs.",
    loading: "Loading FLOATs...",
  }}>
  <thead slot="head">
    <tr>
      <th>Burn</th>
      <th> Image </th>
      <th>
        Name
        <Sort key="eventName" on:sort={onSortString} />
      </th>
      <th>
        Serial
        <Sort key="serial" on:sort={onSortNumber} />
      </th>
      <th>
        Date
        <Sort key="dateReceived" dir="desc" on:sort={onSortNumber} />
      </th>
    </tr>
  </thead>
  <tbody>
    {#each rows2 as row, index (row)}
      <Row {index} on:click={() => onCellClick(row)}>
        <td
          ><input
            checked={row.id in $selectedToBurn}
            on:click={() => toggleBurn(row)}
            type="checkbox" /></td>
        <td data-label="Image"
          ><img
            alt=""
            class="table-image"
            src="https://nftstorage.link/ipfs/{row.eventImage}" /></td>
        <td data-label="Name">{row.eventName}</td>
        <td data-label="Serial"><code>#{row.serial}</code></td>
        <td data-label="Received"
          >{formatter.format(row.dateReceived * 1000)}</td>
      </Row>
    {/each}
  </tbody>
</Table>

<style>
  .table-image {
    max-width: 100px;
    max-height: 50px;
    display: block;
    margin: 0 auto;
  }

  td {
    color: white;
  }

  button {
    border-color: white !important;
  }
</style>
