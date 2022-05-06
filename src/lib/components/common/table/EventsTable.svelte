<script>
  //Row component is optional and only serves to render odd/even row, you can use <tr> instead.
  //Sort component is optional

  import Table, { Row, Sort } from "./Table.svelte";
  import { sortNumber, sortString } from "./sorting.js";
  import { formatter } from "$lib/flow/utils";
  import { page } from "$app/stores";

  export let floatEvents;
  let rows = floatEvents;

  let pageCount = 0; //first page
  let pageSize = 25;

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
</script>

<Table
  {pageCount}
  {pageSize}
  {rows}
  let:rows={rows2}
  labels={{
    empty: "This account has not created any events.",
    loading: "Loading events...",
  }}>
  <thead slot="head">
    <tr>
      <th>
        Event
        <Sort key="name" on:sort={onSortString} />
      </th>
      <th> 
        Created 
        <Sort key="dateCreated" on:sort={onSortNumber} />
      </th>
      <th> Groups </th>
      <th> Claimed </th>
    </tr>
  </thead>
  <tbody>
    {#each rows2 as row, index (row)}
      <Row {index} on:click={() => onCellClick(row)}>
        <td data-label="Event">
          <div class="event-block d-flex">
            <div style="margin-right:10px;">
              <a href="/{$page.params.address}/event/{row.eventId}">
                <img
                  alt=""
                  class="table-image"
                  src="https://ipfs.infura.io/ipfs/{row.image}" />
              </a>
            </div>
            <div>
              <a href="/{$page.params.address}/event/{row.eventId}">
                {row.name}
              </a>
              <div class="event-description">{row.description}</div>
            </div>
          </div>
        </td>
        <td data-label="Created">
          <span>{formatter.format(row.dateCreated * 1000)}</span>
        </td>
        <td data-label="Groups">
          <span
            >{row.groups.length > 0 ? "" : " - "}
            {#each row.groups as group}
              <a href="/{$page.params.address}/group/{group}"
                ><div class="group-badge small">{group}</div></a>
            {/each}
          </span>
        </td>
        <td data-label="Claimed">
          <span>{row.totalSupply}</span>
        </td>
      </Row>
    {/each}
  </tbody>
</Table>

<style>
  .table-image {
    max-width: 80px;
    max-height: 40px;
  }

  .event-description {
    line-height: 1;
    opacity: 0.6;
    font-size: 0.6rem;
    color: var(--color);
  }

  td:hover {
    opacity: 0.8;
  }

  @media screen and (max-width: 520px) {
    .event-block {
      justify-content: right;
    }
  }
</style>
