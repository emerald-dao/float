<script lang="ts">
	export let dateReceived: string;

	let date = new Date(Number(dateReceived) * 1000);
</script>

<span class="w-medium">
	{date.getDate()} of {date.toLocaleString('en-US', { month: 'long' })}, {date.getFullYear()}
</span>

<style lang="scss">
	span {
		font-size: 0.65em;
		line-height: 0.65em;
		color: var(--clr-text-off);
		opacity: 0.8;
	}
</style>
