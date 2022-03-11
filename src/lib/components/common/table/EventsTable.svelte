<script>
  //Row component is optional and only serves to render odd/even row, you can use <tr> instead.
    //Sort component is optional
    
    import Table, { Row, Sort } from "./Table.svelte";
    import { sortNumber, sortString } from "./sorting.js";
    import { formatter } from "$lib/flow/utils";
    import { page } from "$app/stores";
    
    export let floatEvents;
    let rows = floatEvents;
    
    console.log('EventsTable:', floatEvents);
    
    let pageCount = 0; //first page
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
          Event
          <Sort key="name" on:sort={onSortString} />
        </th>
        <th>
          Created
        </th>
        <th>
          Groups
        </th>
      </tr>
    </thead>
    <tbody>
      {#each rows2 as row, index (row)}
      <Row {index} on:click={() => onCellClick(row)}>
        <td data-label="Event">
          <div class="d-flex">
            <div style="margin-right:10px;">
              <a href="/{$page.params.address}/event/{row.eventId}">
                <img alt="" class="table-image" src="https://ipfs.infura.io/ipfs/{row.image}" />
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
        <td data-lable="Created">{formatter.format(row.dateCreated * 1000)}</td>
        <td data-label="Groups">
          <span>{row.groups.length > 0 ? "" : " - " } 
            {#each row.groups as group}
            <a href="{$page.params.address}/group/{group}"><div class="group-badge small">{group}</div></a>
            {/each}
          </span>
        </td>
      </Row>
      {/each}
    </tbody>
  </Table>
  
  <style>
    .table-image {
      max-width: 75px;
      height:auto;
    }
    
    .event-description {
      line-height: 1;
      opacity: 0.6;
      font-size: 0.6rem;
      color: var(--color);
    }
    
    td:hover {
      opacity:0.8;
    }
    
  </style>