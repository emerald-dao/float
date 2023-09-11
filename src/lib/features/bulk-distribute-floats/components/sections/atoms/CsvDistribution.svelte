<script lang="ts">
	import type { DistributionElement } from '$lib/features/bulk-distribute-floats/types/distribution.interface';
	import type { CertificateType } from '$lib/types/event/event-type.type';
	import Papa from 'papaparse';
	import { Button, DropZone } from '@emerald-dao/component-library';
	import Icon from '@iconify/svelte';
	import { hasFLOATCollectionSetUp } from '$flow/actions';
	import { resolveAddressOrFindName } from '$lib/features/bulk-distribute-floats/functions/resolveAddressOrFindName';

	export let certificateType: CertificateType;
	export let csvDist: DistributionElement<typeof certificateType>[];
	export let addToStagingFromCsv: () => void;

	export let csvFiles: File[] = [];

	let validCsv: boolean | 'loading' | undefined;
	let invalidCsvMessage: string;

	interface ParsedCsvRow {
		address: string;
		medal?: string;
	}

	const parseAndSaveCsv = () => {
		validCsv = 'loading';
		if (csvFiles.length > 0) {
			let parsedCSV = Papa.parse(csvFiles[0], {
				download: true,
				header: true, // gives us an array of objects
				dynamicTyping: true,

				complete: async ({ data }) => {
					if (await checkValidCsv(data)) {
						validCsv = true;
						csvDist = data.map((row, i) => {
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
					}
				}
			});
		}

		const checkValidCsv = async (csvData: unknown[]): Promise<boolean> => {
			for (let i = 0; i < csvData.length; i++) {
				if (typeof csvData[i] !== 'object' && !csvData[i]?.hasOwnProperty('address')) {
					invalidCsvMessage = 'Wrong CSV format';
					return false;
				} else {
					const address = await resolveAddressOrFindName((csvData[i] as ParsedCsvRow).address);

					let addressIsValid = await hasFLOATCollectionSetUp(address);

					if (!addressIsValid) {
						invalidCsvMessage = `Address ${(csvData[i] as ParsedCsvRow).address} is not valid`;
						return false;
					}
				}
			}

			return true;
		};
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
</style>
