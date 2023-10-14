<script lang="ts">
	import LibLoader from './LibLoader.svelte';

	export let unix: number;

	let countdownString = '';
</script>

<LibLoader
	url="https://cdn.jsdelivr.net/npm/countdown@2.6.0/countdown.min.js"
	on:loaded={() => setInterval(() => (countdownString = countdown(unix * 1000)), 1000)}
	uniqueId={+new Date()}
/>
<p class="large">{countdownString}</p>
