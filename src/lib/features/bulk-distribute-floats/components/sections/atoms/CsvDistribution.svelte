<script lang="ts">
	import type { DistributionElement } from '$lib/features/bulk-distribute-floats/types/distribution.interface';
	import type { CertificateType } from '$lib/types/event/event-type.type';
	import Papa from 'papaparse';
	import { Button, DropZone } from '@emerald-dao/component-library';
	import Icon from '@iconify/svelte';
	import { hasFLOATCollectionSetUp, hasFLOATCollectionSetUpBatch } from '$flow/actions';

	export let certificateType: CertificateType;
	export let csvDist: DistributionElement<typeof certificateType>[];
	export let addToStagingFromCsv: () => void;

	export let csvFiles: File[] = [];

	let validCsv: boolean | 'loading' | undefined;
	let invalidCsvMessage: string;
	let omittedCsvRows: ParsedCsvRow[] = [];

	interface ParsedCsvRow {
		address: string;
		medal?: string;
	}

	const parseAndSaveCsv = () => {
		// prevents this function from running twice for some reason
		if (validCsv === 'loading') return;
		validCsv = 'loading';
		if (csvFiles.length > 0) {
			let parsedCSV = Papa.parse(csvFiles[0], {
				download: true,
				header: true, // gives us an array of objects
				dynamicTyping: true,
				complete: async ({ data }) => {
					const { success, filteredRows } = await checkValidCsv(data);
					if (success) {
						validCsv = true;
						csvDist = filteredRows.map((row, i) => {
							if (certificateType === 'medal') {
								return {
									address: (row as ParsedCsvRow).address,
									medal: (row as ParsedCsvRow).medal ?? 'participation'
								};
							} else {
								return {
									address: (row as ParsedCsvRow).address,
									medal: null
								};
							}
						}) as DistributionElement<typeof certificateType>[];
					} else {
						validCsv = false;
						csvFiles = [];
						omittedCsvRows = [];
					}
				}
			});
		}

		const checkValidCsv = async (
			csvData: unknown[]
		): Promise<{ success: boolean; filteredRows: ParsedCsvRow[] }> => {
			let addresses: string[] = [];
			for (let i = 0; i < csvData.length; i++) {
				if (typeof csvData[i] !== 'object' || !csvData[i]?.hasOwnProperty('address')) {
					invalidCsvMessage = 'Wrong CSV format';
					return {
						success: false,
						filteredRows: []
					};
				}
				addresses.push((csvData[i] as ParsedCsvRow).address);
			}

			const { addressesNotSetup } = await hasFLOATCollectionSetUpBatch(addresses);
			let filteredRows: ParsedCsvRow[] = [];
			for (let j = 0; j < csvData.length; j++) {
				if (addressesNotSetup.includes((csvData[j] as ParsedCsvRow).address)) {
					omittedCsvRows.push(csvData[j] as ParsedCsvRow);
				} else {
					filteredRows.push(csvData[j] as ParsedCsvRow);
				}
			}

			return {
				success: true,
				filteredRows
			};
		};
	};

	const downloadCSV = async (omittedCsvRows: ParsedCsvRow[]) => {
		let csvContent =
			'data:text/csv;charset=utf-8,' + omittedCsvRows.map((row) => row.address).join('\n');
		var encodedUri = encodeURI(csvContent);

		var downloadLink = document.createElement('a');
		downloadLink.href = encodedUri;
		downloadLink.download = 'omitted.csv';

		document.body.appendChild(downloadLink);
		downloadLink.click();
		document.body.removeChild(downloadLink);
	};

	const emptyCsv = () => {
		csvDist = [];
	};

	$: if (csvFiles.length > 0) parseAndSaveCsv();
	$: if (csvFiles.length === 0) emptyCsv();
</script>

<form id="dist-form" on:submit|preventDefault={() => addToStagingFromCsv()} autocomplete="off">
	<p class="xsmall">
		For an example CSV file, download <a
			href={certificateType === 'medal'
				? `/example-bulk-distribution-medal.csv`
				: `/example-bulk-distribution.csv`}>this</a
		>.
	</p>
	<div class="wrapper">
		<DropZone
			name="distribution-csv"
			accept={['text/csv']}
			bind:bindValue={csvFiles}
			maxAmountOfFiles={1}
		/>
		{#if validCsv === true && csvFiles.length > 0}
			<p class="csv-state-message success xsmall row-1 align-center">
				<Icon icon="tabler:check" />
				CSV is valid
			</p>
			{#if omittedCsvRows.length > 0}
				<p class="csv-state-message alert xsmall align-center">
					<Icon icon="tabler:alert-triangle-filled" />
					<span on:click|preventDefault={() => downloadCSV(omittedCsvRows)} class="mouse-pointer"
						>Click here</span
					> to view addresses that were omitted because they do not have a FLOAT Collection set up.
				</p>
			{/if}
		{:else if validCsv === false}
			<p class="csv-state-message alert xsmall align-center">
				<Icon icon="tabler:x" />
				{invalidCsvMessage ?? 'CSV is invalid'}
			</p>
		{:else if validCsv === 'loading'}
			<p class="csv-state-message loading xsmall align-center">
				<Icon icon="svg-spinners:180-ring" />
				Analyzing CSV validity
			</p>
		{/if}
	</div>
	<Button
		form="dist-form"
		type="ghost"
		color="neutral"
		width="full-width"
		state={csvDist.length > 0 && validCsv ? 'active' : 'disabled'}
		>Add <Icon icon="tabler:arrow-narrow-right" /></Button
	>
</form>

<style lang="scss">
	form {
		margin-block: var(--space-4);
		display: flex;
		flex-direction: column;
		gap: var(--space-6);
		overflow: visible;

		.csv-state-message {
			margin-top: var(--space-1);
			max-width: 280px;

			&.success {
				color: var(--clr-primary-main);
			}

			&.alert {
				color: var(--clr-alert-main);
			}

			&.loading {
				color: var(--clr-tertiary-main);
			}
		}
	}

	.mouse-pointer {
		cursor: pointer;
		text-decoration: underline;
	}
</style>
