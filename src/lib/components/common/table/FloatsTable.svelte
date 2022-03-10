<script>
  //Row component is optional and only serves to render odd/even row, you can use <tr> instead.
  //Sort component is optional

  import Table, { Row, Sort } from "./Table.svelte";
  import { sortNumber, sortString } from "./sorting.js";
  import { page } from "$app/stores";

  export let floats;
  let rows2 = floats;
  let rows = floats;
  
  console.log('FloatsTable:', floats);
  
  let pageCount = 0; //first page
  let pageSize = 25; 

  function onCellClick(row) {
    return; // window.location = `/${row.address}`
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
        Host
        <Sort key="eventHost" on:sort={onSortString} />
      </th>
    </tr>
  </thead>
  <tbody>
    {#each rows2 as row, index (row)}
      <Row {index} on:click={() => onCellClick(row)}>
        <td data-label="Image"><a href="{$page.path}/{row.eventId}/{row.serial}"><img alt="" class="table-image" src="https://ipfs.infura.io/ipfs/{row.eventImage}" /></a></td>
        <td data-label="Name"><a href="{$page.path}/{row.eventId}/{row.serial}">{row.eventName}</a></td>
        <td data-label="Serial"><a href="{$page.path}/{row.eventId}/{row.serial}"><code>#{row.serial}</code></a></td>
        <td data-label="Host"><span class="mono"><a href="/{row.eventHost}">{row.eventHost}</a></span></td>
      </Row>
    {/each}
  </tbody>
</Table>

<style>
  .table-image {
    width: auto;
    height: 24px;
  }

</style>