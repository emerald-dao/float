<script lang="ts">
	import type { Distribution } from '$lib/features/bulk-distribute-floats/types/distribution.interface';
	import type { CertificateType } from '$lib/types/event/event-type.type';
	import UserSearchBar from '../../atoms/searchBar/UserSearchBar.svelte';

	export let addressInputValue: string;
	export let certificateType: CertificateType;
	export let distribution: Distribution<typeof certificateType>;
	export let addToStagingFromInput: () => void;
</script>

<form id="dist-form" on:submit|preventDefault={() => addToStagingFromInput()} autocomplete="off">
	<UserSearchBar
		bind:addressInputValue
		autoFocus={true}
		customError={distribution.distributionObjects.find(
			(distObj) => distObj.address === addressInputValue
		)
			? 'Address already added'
			: ''}
	/>
</form>

<style lang="scss">
	form {
		margin-block: var(--space-4);
		display: flex;
		flex-direction: column;
		gap: var(--space-6);
		overflow: visible;
	}
</style>
