<script lang="ts">
	import { page } from '$app/stores';
	import DistributionStaging from './sections/DistributionStaging.svelte';
	import DistributionForms from './sections/DistributionForms.svelte';
	import { Button, Modal, getModal } from '@emerald-dao/component-library';
	import { fly } from 'svelte/transition';
	import { distributeFloats } from '../functions/distributeFloats';

	let distStaging: string[] = [];

	let addressInputValue = '';
	let csvDist: string[] = [];

	$: id = `distribute-floats-${$page.params.id}`;

	const addToStaging = (validForm: boolean) => {
		if (validForm) {
			distStaging = [...distStaging, addressInputValue, ...csvDist];
		} else {
			distStaging = [...distStaging, ...csvDist];
		}
		addressInputValue = '';
	};

	const handleOpenModal = () => {
		getModal(id).open();
	};

	const handleDistributeFloats = () => {
		distributeFloats($page.params.id, distStaging);
	};
</script>

<Button on:click={handleOpenModal} size="small">Distribute FLOATs</Button>
<Modal {id} background="var(--clr-surface-primary)">
	<div class="main-wrapper">
		<div class="forms-wrapper sub-wrapper column">
			<div class="introduction">
				<h5 class="w-medium">Distribute FLOATs</h5>
				<p class="small">Add the wallets you want to distribute tokens to.</p>
			</div>
			<slot />
			<DistributionForms bind:addressInputValue bind:csvDist {addToStaging} />
		</div>
		<div class="dist-wrapper sub-wrapper">
			<DistributionStaging bind:distStaging />
			<div class="button-wrapper" transition:fly|local={{ y: 10, duration: 400, delay: 100 }}>
				<Button
					width="full-width"
					on:click={handleDistributeFloats}
					state={distStaging.length > 0 ? 'active' : 'disabled'}>Distribute FLOATs</Button
				>
			</div>
		</div>
	</div>
</Modal>

<style lang="scss">
	.main-wrapper {
		display: flex;
		flex-direction: column;
		height: 90vh;
		overflow-y: hidden;
		flex: 1;

		@include mq(small) {
			height: 500px;
			display: grid;
			grid-template-columns: 2fr 3fr;
			gap: var(--space-13);
		}

		.sub-wrapper {
			display: flex;
			flex-direction: column;
			gap: var(--space-3);
			overflow-y: hidden;
			transition: 3s;

			@include mq(small) {
				gap: 1.4rem;
			}

			&.dist-wrapper {
				flex: 1;
			}

			&.forms-wrapper {
				height: fit-content;
				margin-bottom: 0;
				padding-bottom: 0;

				.introduction {
					h5 {
						margin-bottom: var(--space-2);
						margin-top: 0;
					}
				}
			}

			.button-wrapper {
				position: sticky;
				bottom: 0px;
			}
		}
	}
</style>
