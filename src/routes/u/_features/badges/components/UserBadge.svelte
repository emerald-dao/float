<script lang="ts">
	import { fly } from 'svelte/transition';
	import type { Level } from '../badges.interface';
	import Icon from '@iconify/svelte';

	export let badgeLevel: Level;
	export let level: number;
	export let nextLevelGoal: string | undefined = undefined;
	export let imageWidth = '65px';

	let hover = false;
</script>

<div class="column-1 align-center main-wrapper">
	<div class="column-2 align-center">
		<img
			src={badgeLevel.image}
			class:off={level === 0}
			alt="Badge"
			width={imageWidth}
			height={imageWidth}
			on:mouseenter={() => (hover = true)}
			on:mouseleave={() => (hover = false)}
			class="shadow-medium"
		/>
		<span class="level xsmall">Level {level}</span>
	</div>
	{#if hover}
		<div class="description-wrapper shadow-large" transition:fly|local={{ y: 10, duration: 400 }}>
			<span class="title">{badgeLevel.name}</span>
			<span class="goal xsmall" class:off={level === 0}>
				{#if level === 0}
					User has to {badgeLevel.goal.toLowerCase()} to unlock this badge.
				{:else}
					<Icon icon="tabler:circle-check" />
					{badgeLevel.goal}
				{/if}
			</span>
			{#if !(level === 0)}
				<span class="description">{badgeLevel.description}</span>
			{/if}
			{#if nextLevelGoal}
				<span class="next-level xsmall">
					User has to {nextLevelGoal.toLowerCase()} to unlock the next level.
				</span>
			{/if}
		</div>
	{/if}
</div>

<style lang="scss">
	.main-wrapper {
		position: relative;
		display: inline-block;

		img {
			border-radius: 50%;

			&.off {
				opacity: 0.2;
			}
		}

		.level {
			background-color: var(--clr-neutral-badge);
			padding-inline: var(--space-2);
			border-radius: var(--radius-1);
		}

		.description-wrapper:after {
			position: absolute;
			bottom: 100%;
			left: 24px;
			width: 0;
			border-bottom: 5px var(--clr-surface-primary) solid;
			border-right: 5px solid transparent;
			border-left: 5px solid transparent;
			content: ' ';
			font-size: 0;
			line-height: 0;
		}

		.description-wrapper {
			position: absolute;
			background-color: var(--clr-surface-primary);
			padding: var(--space-4);
			border-radius: var(--radius-1);
			width: 300px;
			display: flex;
			flex-direction: column;
			gap: var(--space-2);
			z-index: 9999;
			margin-top: 10px;

			.title {
				font-size: var(--font-size-1);
				color: var(--clr-heading-main);
			}

			.goal {
				color: var(--clr-primary-main);
				display: flex;
				flex-direction: row;
				align-items: center;
				gap: var(--space-1);

				&.off {
					color: var(--clr-alert-main);
				}
			}

			.next-level {
				color: #777;
			}

			.description {
				font-size: var(--font-size-1);
			}
		}
	}
</style>
