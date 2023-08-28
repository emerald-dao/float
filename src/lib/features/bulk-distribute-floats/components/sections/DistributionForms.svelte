<script lang="ts">
	import { fly } from 'svelte/transition';
	import Papa from 'papaparse';
	import { Button, DropZone } from '@emerald-dao/component-library';
	import Icon from '@iconify/svelte';
	import { InputWrapper, Tabs, Tab, TabList, TabPanel } from '@emerald-dao/component-library';
	import validationSuite from './validation';
	import type { SuiteRunResult } from 'vest';
	import { hasFLOATCollectionSetUp } from '$flow/actions';

	export let addressInputValue: string;
	export let csvDist: string[];
	export let addToStaging: (validForm: boolean) => void;

	let csvFiles: File[] = [];
	let validCsv: boolean | 'loading' | undefined;
	let invalidCsvMessage: string;

	interface ParsedCsvRow {
		address: string;
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
						csvDist = data.map((row) => (row as ParsedCsvRow).address) as string[];
					} else {
						validCsv = false;
						csvFiles = [];
					}
				}
			});
		}

		const checkValidCsv = async (csvData: unknown[]): Promise<boolean> => {
			for (let i = 0; i < csvData.length; i++) {
				let addressIsValid = await checkValidAddress(csvData[i]);

				if (!addressIsValid) {
					return false;
				}
			}

			return true;
		};
	};

	const checkValidAddress = async (obj: unknown): Promise<boolean> => {
		if (typeof obj === 'object') {
			if (obj?.hasOwnProperty('address')) {
				if (
					(obj as ParsedCsvRow).address.length === 18 &&
					(obj as ParsedCsvRow).address.startsWith('0x')
				) {
					let hasFloatCollection = await hasFLOATCollectionSetUp((obj as ParsedCsvRow).address);

					if (hasFloatCollection) {
						invalidCsvMessage = '';
						return true;
					} else {
						invalidCsvMessage = `Address ${
							(obj as ParsedCsvRow).address
						} doesn't have a FLOAT collection set up`;
					}
				} else {
					invalidCsvMessage = `Address ${
						(obj as ParsedCsvRow).address
					} doesn't have the correct format`;
				}
			} else {
				invalidCsvMessage = 'Wrong CSV format';
			}
		} else {
			invalidCsvMessage = 'Wrong CSV format';
		}

		return false;
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

	span {
		color: inherit;
	}
</style>
