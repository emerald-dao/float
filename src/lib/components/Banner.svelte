<script>
    export let time;
    export let isScheduled;

    let scheduled = ((isScheduled) ? 'scheduled' : 'unscheduled');
</script>

<div class="notice">
    <strong>Important!</strong> Flow Mainnet is undergoing {scheduled} <a href='https://status.onflow.org' target='_blank'>maintenance</a> around {time}. Transactions will fail during this time.
</div> 