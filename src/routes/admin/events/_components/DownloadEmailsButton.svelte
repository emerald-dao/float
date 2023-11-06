<script lang="ts">
	import type { Event } from '$lib/types/event/event.interface';
	import { fetchEventEmails } from '$lib/utilities/api/fetchEventEmails';
	import { Button } from '@emerald-dao/component-library';
	import Icon from '@iconify/svelte';
	export let eventId: string;
	async function downloadEmails() {
		const eventEmails = await fetchEventEmails(eventId);
		downloadCSV(eventEmails);
	}
	const downloadCSV = async (rows: { user_address: string; email: string }[]) => {
		let csvContent = 'data:text/csv;charset=utf-8,';
		csvContent += 'user_address,email\n';
		csvContent += rows.map((row) => row.user_address + ',' + row.email).join('\n');
		var encodedUri = encodeURI(csvContent);
		var downloadLink = document.createElement('a');
		downloadLink.href = encodedUri;
		downloadLink.download = 'emails.csv';
		document.body.appendChild(downloadLink);
		downloadLink.click();
		document.body.removeChild(downloadLink);
	};
</script>

<Button on:click={downloadEmails} size="small" type="ghost">
	<Icon icon="tabler:download" />
	Download Emails
</Button>