<script>
  import countdown from 'countdown';

  export let unix;

  let countdownString = countdown(unix*1000);

  setInterval(() => countdownString = countdown(unix*1000), 1000);
</script>

<span>{countdownString}</span>
