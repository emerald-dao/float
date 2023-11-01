<script lang="ts">
	import { getEventClaims } from '$flow/actions';
	import type { Claim } from '$lib/types/event/event-claim.interface';
	import { Button } from '@emerald-dao/component-library';
	import Icon from '@iconify/svelte';

	export let eventHost: string;
	export let eventId: string;

	async function downloadClaims() {
		const claimers = await getEventClaims(eventHost, eventId);
		downloadCSV(claimers);
	}

	const downloadCSV = async (rows: Claim[]) => {
		let csvContent = 'data:text/csv;charset=utf-8,';
		csvContent += 'address,serial\n';
		csvContent += rows.map((row) => row.address + ',' + row.serial).join('\n');
		var encodedUri = encodeURI(csvContent);
		var downloadLink = document.createElement('a');
		downloadLink.href = encodedUri;
		downloadLink.download = 'claims.csv';
		document.body.appendChild(downloadLink);
		downloadLink.click();
		document.body.removeChild(downloadLink);
	};
</script>

<Button on:click={downloadClaims} size="small" type="ghost">
	<Icon icon="tabler:download" />
	Download Claims
</Button>
