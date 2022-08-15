<script>
  import { t } from "svelte-i18n";
  //Row component is optional and only serves to render odd/even row, you can use <tr> instead.
  //Sort component is optional
  import Table, { Row, Sort } from "../../common/table/Table.svelte";
  import { sortNumber, sortString } from "../../common/table/sorting.js";
  import { formatter } from "$lib/flow/utils";
  import { createEventDispatcher } from "svelte";

  const dispatch = createEventDispatcher();

  /** @type {Array<import('../types').PickableEvent>} */
  export let pickableEvents;
  /** @type {string} */
  export let ownerAddress;

  let rows = pickableEvents;
  if (rows?.length > 0) {
    rows = rows.sort((a, b) => b.dateCreated - a.dateCreated);
  }

  let pageCount = 0; //first page
  let pageSize = 10;
  let rowsVisible = [];

  function onSelected(row) {
    dispatch("pickChanged", {
      host: ownerAddress,
      eventId: row.event.eventId,
      picked: row.picked,
    });
  }

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
  let:rows={rowsVisible}
  labels={{
    empty: "This account has not created any events.",
    loading: "Loading events...",
  }}
>
  <thead slot="head">
    <tr>
      <th> {$t("common.eventsTable.select")} </th>
      <th>
        {$t("common.eventsTable.event")}
        <Sort key="name" on:sort={onSortString} />
      </th>
      <th>
        {$t("common.eventsTable.created")}
        <Sort key="dateCreated" dir="desc" on:sort={onSortNumber} />
      </th>
      <th> {$t("common.main.groups")} </th>
      <th> {$t("common.eventsTable.claimed")} </th>
    </tr>
  </thead>

  <tbody>
    {#each rowsVisible as row, index (row)}
      <Row {index} on:click={() => onCellClick(row)}>
        <td data-label="Select">
          <input
            type="checkbox"
            name="picked"
            bind:checked={row.picked}
            on:change={function () {
              onSelected(row);
            }}
          />
        </td>
        <td data-label="Event">
          <div class="event-block d-flex">
            <div style="margin-right:10px;">
              <a
                href="/{ownerAddress}/event/{row.event.eventId}"
                target="_blank"
              >
                <img
                  alt=""
                  class="table-image"
                  src="https://cloudflare-ipfs.com/ipfs/{row.event.image}"
                />
              </a>
            </div>
            <div>
              <a
                href="/{ownerAddress}/event/{row.event.eventId}"
                target="_blank"
              >
                {row.event.name}
              </a>
              <div class="event-description">{row.event.description}</div>
            </div>
          </div>
        </td>
        <td data-label="Created">
          <span>{formatter.format(row.event.dateCreated * 1000)}</span>
        </td>
        <td data-label="Groups">
          <span
            >{row.event.groups.length > 0 ? "" : " - "}
            {#each row.event.groups as group}
              <a href="/{ownerAddress}/group/{group}" target="_blank">
                <div class="group-badge small">{group}</div>
              </a>
            {/each}
          </span>
        </td>
        <td data-label="Claimed">
          <span>{row.event.totalSupply}</span>
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
