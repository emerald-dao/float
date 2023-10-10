<script lang="ts">
	import ClaimButtonStatus from '../../../../event/_components/ClaimButtonStatus.svelte';

	export let data;

	let secretCode = data.event.verifiers.secret?.secret ?? '';
</script>

<div style="padding: var(--space-2);">
	<ClaimButtonStatus
		event={data.event}
		{secretCode}
		free={data.event.price !== null || Number(data.event.price) === 0}
		embed={true}
	/>
</div>
