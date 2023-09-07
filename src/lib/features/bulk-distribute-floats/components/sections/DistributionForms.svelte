<script lang="ts">
	import type { CertificateType } from '$lib/types/event/event-type.type';
	import { fly } from 'svelte/transition';
	import Papa from 'papaparse';
	import { Button, DropZone } from '@emerald-dao/component-library';
	import Icon from '@iconify/svelte';
	import { Tabs, Tab, TabList, TabPanel } from '@emerald-dao/component-library';
	import validationSuite from '../atoms/searchBar/validation';
	import { hasFLOATCollectionSetUp } from '$flow/actions';
	import type { Distribution, DistributionElement } from '../../types/distribution.interface';
	import UserSearchBar from '../atoms/searchBar/UserSearchBar.svelte';

	export let addressInputValue: string;
	export let certificateType: CertificateType;
	export let csvDist: DistributionElement<typeof certificateType>[];
	export let addToStaging: () => void;
	export let distribution: Distribution<typeof certificateType>;

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
						csvDist = data.map((row) => {
							return {
								address: (row as ParsedCsvRow).address,
								medal: 'gold'
							};
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

	export const restartValidation = () => {
		validationSuite.reset();
		res = validationSuite.get();
	};

	const emptyCsv = () => {
		csvDist = [];
	};

	$: if (csvFiles.length > 0) parseAndSaveCsv();
	$: if (csvFiles.length === 0) emptyCsv();

	let res = validationSuite.get();
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
				on:submit|preventDefault={() => addToStaging()}
				autocomplete="off"
				class="wrapper"
			>
				<UserSearchBar
					bind:addressInputValue
					customError={distribution.distributionObjects.find(
						(distObj) => distObj.address === addressInputValue
					)
						? 'Address already added'
						: ''}
				/>
				<!-- {#if certificateType === 'medal'}
					<select bind:value={medalTypeSelectValue}>
						{#each MEDAL_TYPES as type}
							<option value={type}>{`${type.charAt(0).toUpperCase() + type.slice(1)}`}</option>
						{/each}
					</select>
				{/if} -->
			</form>
		</TabPanel>
		<TabPanel>
			<form
				id="dist-form"
				on:submit|preventDefault={() => addToStaging()}
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
		display: flex;
		flex-direction: column;
		gap: var(--space-6);
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
