<script>
  //Row component is optional and only serves to render odd/even row, you can use <tr> instead.
  //Sort component is optional

  import Table, { Row, Sort } from "./Table.svelte";
  import { sortNumber } from "./sorting.js";
  import { page } from "$app/stores";

  export let rows = [];
  let pageCount = 0; //first page
  let pageSize = 25; 
  console.log($page.path)

  function onCellClick(row) {
    window.location = `/${row.address}`
  }

  function onSortNumber(event) {
    event.detail.rows = sortNumber(
      event.detail.rows,
      event.detail.dir,
      event.detail.key
    );
  }
</script>

<Table {pageCount} {pageSize} {rows} let:rows={rows2}>
  <thead slot="head">
    <tr>
      <th>
        Serial
        <Sort key="serial" on:sort={onSortNumber} />
      </th>
      <th>
        Address
      </th>
    </tr>
  </thead>
  <tbody>
    {#each rows2 as row, index (row)}
      <Row {index} on:click={() => onCellClick(row)}>
        <td data-label="Serial"><a href="{$page.path}/{row.serial}"><code>#{row.serial}</code></a></td>
        <td data-label="Address"><span class="mono"><a href="/{row.address}">{row.address}</a></span></td>
      </Row>
    {/each}
  </tbody>
</Table>
