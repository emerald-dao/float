<script lang="ts">
	import { applyAction, enhance } from '$app/forms';
	import type { FLOAT } from '$lib/types/float/float.interface';
	import Icon from '@iconify/svelte';
	import { getContext } from 'svelte';
	import type createFetchStore from '../../../_stores/fetchStore';
	import { network } from '$flow/config';

	export let float: FLOAT;

	let pinnedFloatsIds: ReturnType<typeof createFetchStore<string[]>> = getContext('pinnedFloats');

	$: isFloatPinned = $pinnedFloatsIds.includes(float.id);
</script>

{#if isFloatPinned}
	<form
		method="POST"
		action={`/admin/my-collection/${float.id}?/unpinFloat`}
		use:enhance={() => {
			return async ({ result }) => {
				if (result.type === 'success') {
					await applyAction(result);

					if (result.status === 204) {
						pinnedFloatsIds.invalidate();
					}
				}
			};
		}}
	>
		<input type="hidden" name="floatId" value={float.id} />
		<button>
			<Icon icon="tabler:star-filled" width="18" color="#f2d052" />
		</button>
	</form>
{:else}
	<form
		method="POST"
		action={`/admin/my-collection/${float.id}?/pinFloat`}
		use:enhance={() => {
			return async ({ result }) => {
				if (result.type === 'success') {
					await applyAction(result);

					if (result.status === 204) {
						pinnedFloatsIds.invalidate();
					}
				}
			};
		}}
	>
		<input type="hidden" name="floatId" value={float.id} />
		<input type="hidden" name="userAddress" value={float.originalRecipient} />
		<input type="hidden" name="network" value={network} />
		<button>
			<Icon icon="tabler:star" width="18" />
		</button>
	</form>
{/if}

<style lang="scss">
	button {
		all: unset;
		cursor: pointer;
	}
</style>
