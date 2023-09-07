<script lang="ts">
	import { MEDAL_TYPES, type MedalType } from '$lib/types/event/medal-types.type';
	import { UserProfileLabel } from '@emerald-dao/component-library';
	import Icon from '@iconify/svelte';
	import { createEventDispatcher } from 'svelte';
	import { fly } from 'svelte/transition';

	const dispatch = createEventDispatcher();

	function deleteDist() {
		dispatch('deleteDist');
	}

	export let forAccount: string;
	export let medalType: MedalType | null;
</script>

<div transition:fly|local={{ x: 10, duration: 300 }}>
	<div class="main-wrapper row-4 align-center">
		{#if medalType}
			<select bind:value={medalType}>
				{#each MEDAL_TYPES as type}
					<option value={type}>
						{#if type === 'gold'}
							{`🥇 `}
						{:else if type === 'silver'}
							{`🥈 `}
						{:else if type === 'bronze'}
							{`🥉 `}
						{/if}
						{`${type.charAt(0).toUpperCase() + type.slice(1)}`}
					</option>
				{/each}
			</select>
		{/if}
		<div class={`card-primary row-space-between align-center ${medalType}`}>
			<UserProfileLabel address={forAccount} />
		</div>
		<div class="clickable" on:click={deleteDist} on:keydown>
			<Icon icon="tabler:trash" />
		</div>
	</div>
</div>

<style lang="scss">
	.main-wrapper {
		width: 100%;

		.card-primary {
			width: 100%;
			padding: var(--space-3) var(--space-4);
			border-radius: var(--radius-2);
		}

		.clickable {
			cursor: pointer;
		}

		.gold {
			background: linear-gradient(
				150deg,
				rgb(253, 241, 204) 0%,
				rgb(255, 250, 232) 20%,
				rgb(255, 246, 221) 30%,
				rgb(255, 249, 227) 60%,
				rgb(255, 244, 217) 70%,
				rgb(255, 251, 234) 85%,
				rgb(255, 245, 216) 90%,
				rgb(255, 246, 217) 100%
			);
		}

		.silver {
			background: linear-gradient(
				150deg,
				rgb(227, 227, 227) 0%,
				rgb(221, 221, 221) 10%,
				rgb(236, 236, 236) 25%,
				rgb(212, 212, 212) 50%,
				rgb(232, 232, 232) 70%,
				rgb(232, 232, 232) 85%,
				rgb(236, 236, 236) 90%,
				rgb(227, 227, 227) 100%
			);
		}

		.bronze {
			background: linear-gradient(
				150deg,
				rgb(243, 226, 209) 0%,
				rgb(249, 218, 185) 20%,
				rgb(247, 221, 194) 30%,
				rgb(248, 232, 216) 60%,
				rgb(250, 231, 211) 70%,
				rgb(246, 221, 195) 85%,
				rgb(255, 228, 205) 90%,
				rgb(239, 232, 226) 100%
			);
		}
	}
</style>
