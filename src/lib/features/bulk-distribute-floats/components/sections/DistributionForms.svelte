<script lang="ts">
	import { fly } from 'svelte/transition';
	import Papa from 'papaparse';
	import { Button, DropZone } from '@emerald-dao/component-library';
	import Icon from '@iconify/svelte';
	import { InputWrapper, Tabs, Tab, TabList, TabPanel } from '@emerald-dao/component-library';
	import validationSuite from './validation';
	import type { SuiteRunResult } from 'vest';

	export let addressInputValue: string;
	export let csvDist: string[];
	export let addToStaging: (validForm: boolean) => void;

	let csvFiles: File[] = [];
	let validCsv = false;

	interface ParsedCsvRow {
		address: string;
	}

	const parseAndSaveCsv = () => {
		if (csvFiles.length > 0) {
			let parsedCSV = Papa.parse(csvFiles[0], {
				download: true,
				header: true, // gives us an array of objects
				dynamicTyping: true,
				complete: ({ data }) => {
					if (checkValidCsv(data)) {
						csvDist = data.map((row) => (row as ParsedCsvRow).address) as string[];
					} else {
						alert('CSV is not valid');
						csvFiles = [];
					}
				}
			});
		}

		// Check if CSV is valid
		const checkValidCsv = (csvData: unknown[]): boolean => {
			// Check if al elements in the array have an address property
			return csvData.every((obj) => {
				if (typeof obj === 'object') {
					if (obj?.hasOwnProperty('address')) {
						// check that all addresses have 18 chars of length and start with a 0x
						return (
							(obj as ParsedCsvRow).address.length === 18 &&
							(obj as ParsedCsvRow).address.startsWith('0x')
						);
					}
				}

				return false;
			});
		};
	};

	const emptyCsv = () => {
		csvDist = [];
	};

	$: if (csvFiles.length > 0) parseAndSaveCsv();
	$: if (csvFiles.length === 0) emptyCsv();

	let res = validationSuite.get();
	let addressPending: boolean;
	let addressPendingMessage = ['Checking if address exists in the blockchain'];

	const handleChange = (input: Event) => {
		const target = input.target as HTMLInputElement;
		res = validationSuite(target.value);

		if (target.name === 'address') {
			addressPending = true;
		}

		(res as SuiteRunResult).done((result) => {
			res = result;
			addressPending = false;
		});
	};
</script>

<div transition:fly|local={{ duration: 200, y: 30 }}>
	<Tabs>
		<TabList>
			<Tab>
				<span class="xsmall"> Manual distribution </span>
			</Tab>
			<Tab><span class="xsmall">Bulk distribution (CSV)</span></Tab>
		</TabList>
		<TabPanel>
			<form
				id="dist-form"
				on:submit|preventDefault={() => addToStaging(res.isValid())}
				autocomplete="off"
				class="wrapper"
			>
				<InputWrapper
					name="address"
					label="Address"
					pending={addressPending}
					pendingMessage={addressPendingMessage}
					errors={res.getErrors('address')}
					isValid={res.isValid('address')}
				>
					<input
						name="address"
						type="text"
						maxlength="18"
						on:input={handleChange}
						bind:value={addressInputValue}
					/>
				</InputWrapper>
				<Button
					form="dist-form"
					type="ghost"
					color="neutral"
					width="full-width"
					state={res.isValid() ? 'active' : 'disabled'}
					>Add <Icon icon="tabler:arrow-narrow-right" /></Button
				>
			</form>
		</TabPanel>
		<TabPanel>
			<form
				id="dist-form"
				on:submit|preventDefault={() => addToStaging(res.isValid())}
				autocomplete="off"
				class="wrapper"
			>
				<p class="xsmall margin-top">
					For an example CSV file, download <a href="/example-bulk-distribution.csv">this</a>.
				</p>
				<div class="wrapper">
					<DropZone
						name="distribution-csv"
						accept={['text/csv']}
						bind:bindValue={csvFiles}
						maxAmountOfFiles={1}
					/>
				</div>
				<Button
					form="dist-form"
					type="ghost"
					color="neutral"
					width="full-width"
					state={csvDist.length > 0 ? 'active' : 'disabled'}
					>Add <Icon icon="tabler:arrow-narrow-right" /></Button
				>
			</form>
		</TabPanel>
	</Tabs>
</div>

<style lang="scss">
	.margin-top {
		margin-top: 15px;
	}

	.wrapper,
	form {
		margin-block: var(--space-4);
	}

	span {
		color: inherit;
	}
</style>
