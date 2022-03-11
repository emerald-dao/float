<script>
  //Row component is optional and only serves to render odd/even row, you can use <tr> instead.
  //Sort component is optional

  import Table, { Row, Sort } from "./Table.svelte";
  import { sortNumber, sortString } from "./sorting.js";
  import { page } from "$app/stores";
  import { formatter } from "$lib/flow/utils";

  export let floats;
  let rows = floats;
  
  let pageCount = 0;
  let pageSize = 25; 

  function onCellClick(row) {
    return;
  }

  function onSortNumber(event) {
    console.log(event.detail);
    event.detail.rows = sortNumber(
      event.detail.rows,
      event.detail.dir,
      event.detail.key
    );
  }

  function onSortString(event) {
    console.log(event.detail);
    event.detail.rows = sortString(
      event.detail.rows,
      event.detail.dir,
      event.detail.key
    );
  }
</script>

<Table {pageCount} {pageSize} {rows} let:rows={rows2} >
  <thead slot="head">
    <tr>
      <th>
        Image
      </th>
      <th>
        Name
        <Sort key="eventName" on:sort={onSortString} />
      </th>
      <th>
        Serial
        <Sort key="serial" on:sort={onSortNumber} />
      </th>
      <th>
        Received
        <!-- <Sort key="dateReceived" on:sort={onSortNumber} /> -->
      </th>
    </tr>
  </thead>
  <tbody>
    {#each rows2 as row, index (row)}
      <Row {index} on:click={() => onCellClick(row)}>
        <td data-label="Image"><a href="{$page.path}/float/{row.id}"><img alt="" class="table-image" src="https://ipfs.infura.io/ipfs/{row.eventImage}" /></a></td>
        <td data-label="Name"><a href="/{row.eventHost}/event/{row.eventId}">{row.eventName}</a></td>
        <td data-label="Serial"><a href="{$page.path}/float/{row.id}"><code>#{row.serial}</code></a></td>
        <td data-label="Received">{formatter.format(row.dateReceived * 1000)}</td>
      </Row>
    {/each}
  </tbody>
</Table>

<style>
  .table-image {
    max-width: 100px;
    max-height: 50px;
  }

</style>